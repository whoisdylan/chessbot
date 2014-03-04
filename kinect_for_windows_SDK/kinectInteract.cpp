#include <stdio.h>
#include "mex.h"
#include <Windows.h>
#include <Ole2.h>

#include <NuiApi.h>
#include <NuiImageCamera.h>
#include <NuiSensor.h>

// Compilation code
// mex '-IC:\Program Files\Microsoft SDKs\Kinect\v1.8\inc' ...       % Kinect SDK
//     '-LC:\Program Files\Microsoft SDKs\Kinect\v1.8\lib\amd64' ... % Kinect Library Folder
//     '-lKinect10' simple.cpp
void destKinect();

#define width 640
#define height 480
#define IMAGE_TIMEOUT 1000000

// Kinect variables
HANDLE *rgbStream;              // The identifier of the Kinect's RGB Camera
HANDLE *depStream;              // The identifier of the Kinect's DEP Camera
INuiSensor* sensor;            // The kinect sensor

mxArray *color_map;
mxArray *depth_map; 

// Setup the sensor (0)
bool initKinect() {
    // Get a working kinect sensor
    int numSensors;
    if (NuiGetSensorCount(&numSensors) < 0 || numSensors < 1) return false;
    if (NuiCreateSensorByIndex(0, &sensor) < 0) return false;
	
	// Array constants for image size
	int const mxRGBDims[3] = {4,width,height};
	int const mxDEPDims[2] = {width,height};

	color_map = mxCreateNumericArray(3,mxRGBDims,mxUINT8_CLASS,mxREAL);
	depth_map = mxCreateNumericArray(2,mxDEPDims,mxUINT16_CLASS,mxREAL);
	rgbStream = (HANDLE *)mxCalloc(1,sizeof(HANDLE));
	depStream = (HANDLE *)mxCalloc(1,sizeof(HANDLE));

    // Initialize sensor
    sensor->NuiInitialize(NUI_INITIALIZE_FLAG_USES_DEPTH | NUI_INITIALIZE_FLAG_USES_COLOR);
    HRESULT a,b,c;
	// Open Color Stream
    a = sensor->NuiImageStreamOpen(
        NUI_IMAGE_TYPE_COLOR,            // Depth camera or rgb camera?
        NUI_IMAGE_RESOLUTION_640x480,    // Image resolution
        0,      // Image stream flags, e.g. near mode
        1,      // Number of frames to buffer
        NULL,   // Event handle
        rgbStream);
    // Open RGB Stream
    b = sensor->NuiImageStreamOpen(
        NUI_IMAGE_TYPE_DEPTH,                     // Depth camera or rgb camera?
        NUI_IMAGE_RESOLUTION_640x480,             // Image resolution
        0,   // Image stream flags, e.g. near mode
        1,      // Number of frames to buffer
        NULL,   // Event handle
        depStream);
    // This will attempt to turn on near mode, if it is kinect for windows :/
    c = NuiImageStreamSetImageFrameFlags(*depStream,NUI_IMAGE_STREAM_FLAG_ENABLE_NEAR_MODE);
    if(a < 0 || b < 0)
        mexPrintf("Image Stream Failed to open with errors: RGB - 0x%x, DEP - 0x%x, EX - 0x%x\n",a,b,c);
	else if (c < 0)
		mexPrintf("Near mode failed to be enabled - Running on Kinect for Xbox 360\n",c);

	// Data was allocated, so show this...
    return (a>=0) && (b>=0);
}
        
// Grab me a frame (1) -- save in RGB_Frame // Call until true
bool getKinectColorData(NUI_IMAGE_FRAME *imageFrame) {
	// Image frame structures
    NUI_LOCKED_RECT LockedRect;
	// Ask if there is a frame...
    if (sensor->NuiImageStreamGetNextFrame(*rgbStream, 0, imageFrame) < 0) return false;
    INuiFrameTexture* texture = imageFrame->pFrameTexture;
	// Lock in the frame
    texture->LockRect(0, &LockedRect, NULL, 0);
    if (LockedRect.Pitch != 0)
    {
		// Get the starting points and end points and destination
        const BYTE* curr = (const BYTE*) LockedRect.pBits;
        const BYTE* dataEnd = curr + (width*height)*4;
        BYTE* dest = (BYTE *)(mxGetData(color_map));
		// Copy everything. (basically a mem copy, but you can do things
		// on every received pixel.  Can extend this to use CUDA if we really
		// want eventually... (this is not the bottle neck of the program)
        while (curr < dataEnd) {
            *dest = *curr;
			dest = dest + 1;
			curr = curr + 1;
        }
    } else return false;
    texture->UnlockRect(0);
    sensor->NuiImageStreamReleaseFrame(*rgbStream, imageFrame);
	texture->Release();
    return true;
}
// Grab me a frame (1) -- save in DEP_Frame // Call until true
bool getKinectDepthData(NUI_IMAGE_FRAME *colorImageFrame) {
	// Image frame allocations
    NUI_IMAGE_FRAME imageFrame;
    NUI_LOCKED_RECT LockedRect;
	// Frame grab
    if (sensor->NuiImageStreamGetNextFrame(*depStream, 0, &imageFrame) < 0) return false;
    INuiFrameTexture* texture = imageFrame.pFrameTexture;
    texture->LockRect(0, &LockedRect, NULL, 0);
    if (LockedRect.Pitch != 0)
    {
		// These are for depth to color
		LONG plColorX;
		LONG plColorY;
		
		LONG lDepthX;
		LONG lDepthY;
		
		NUI_IMAGE_RESOLUTION rez = colorImageFrame->eResolution;
		NUI_IMAGE_VIEW_AREA viewArea= colorImageFrame->ViewArea;
	
		// Get the start and end of the data
        const USHORT* curr = (const USHORT*) LockedRect.pBits;
        unsigned short* dest = (unsigned short *)(mxGetData(depth_map));
		// Clear all the depths
		for(unsigned int x = 0; x < width * height; x++) {
			*(dest + x) = 0;
		}
		// Assign the non zero depths to theri new places.
		for(lDepthY = 0; lDepthY  < height; lDepthY++) {
			for(lDepthX = 0; lDepthX < width; lDepthX++) {
				// Get depth in millimeters (apparently it contains meta data too)
				USHORT NUI_DEP = *(curr + lDepthY*width + lDepthX);
				USHORT depth = NuiDepthPixelToDepth(NUI_DEP);
				// copy over to the output array
				// If it's less than min or greater than max, drop it
				if(NUI_DEP < NUI_IMAGE_DEPTH_MINIMUM || NUI_DEP >  NUI_IMAGE_DEPTH_MAXIMUM) continue;
				HRESULT vld = NuiImageGetColorPixelCoordinatesFromDepthPixelAtResolution(
					rez,imageFrame.eResolution,&viewArea,
					lDepthX,lDepthY,
					NUI_DEP,
					&plColorX, &plColorY
				);
				if(vld == S_OK && plColorX >= 0 && plColorX < width && plColorY >= 0 && plColorY < height)
					*(dest + plColorY*width + plColorX) = depth;
				//else
				//	mexPrintf("PXL CD: 0x%x\n",vld);
            
			}
        }
    } else return false;
    texture->UnlockRect(0);
    sensor->NuiImageStreamReleaseFrame(*depStream, &imageFrame);
	texture->Release();
    return true;
}

// Destroys the kinect structures, should do this on mexAtExit as well... (free everything)
void destKinect() {
	// Close and release the sensors
	if(sensor) {
		sensor->NuiShutdown();
		sensor->Release();
	}
	// free the allocated memory
	if(depth_map)
		mxDestroyArray(depth_map);
	if(color_map)
		mxDestroyArray(color_map);
	if(depStream) {
		CloseHandle(*depStream);
		mxFree(depStream);
	}
	if(rgbStream) {
		CloseHandle(*rgbStream);
		mxFree(rgbStream);
	}
	sensor = NULL;
	depth_map = NULL;
	color_map = NULL;
	depStream = NULL;
	rgbStream = NULL;
	
}



// Gateway function
void mexFunction(int nlhs, mxArray *plhs[],int nrhs,const mxArray *prhs[]) {
    if(nrhs == 0) return; // Do nothing if no input
	// Do the instruction, it does 1 instruction.
	// This lets me keep all the function together.
	double instr = *mxGetPr(prhs[0]);
	// 0 - init
	if(instr == 0) {
		initKinect();
	}
	// 1 - get frame
	unsigned int ct = 0;
	if(instr == 1) {
		bool dep_done = false;
		bool rgb_done = false;
		do {
		  // get color then depth, loop until completed
		  NUI_IMAGE_FRAME colorImageFrame;
		  if(!rgb_done) rgb_done = getKinectColorData(&colorImageFrame);
		  if(rgb_done) // requires color pixel
			if(!dep_done) dep_done = getKinectDepthData(&colorImageFrame);
		  // Every 1000 cycles, it will print to you what it's waiting for.
		  if(ct+1 %1000 == 0)
			mexPrintf("Waiting on %s %s\n",dep_done ? "":"Depth", rgb_done ? "":"Color");
		  if(!dep_done | !rgb_done ) {
			  ct++;
		  }
		} while((!dep_done | !rgb_done) && ct < IMAGE_TIMEOUT);
		if(ct == IMAGE_TIMEOUT)
			mexPrintf("Image timeout - %s %s",dep_done ? "":"Depth", rgb_done ? "":"Color");
		if(nlhs > 0) {
			plhs[0] = color_map;
			if(nlhs > 1) {
				plhs[1] = depth_map;
			}
		}
	}
	// -1 - end
	if(instr == -1) {
		destKinect();
	}
	// If end, DO NOT PERSIST
    mexMakeArrayPersistent(color_map);
    mexMakeArrayPersistent(depth_map);
    mexMakeMemoryPersistent(rgbStream);
    mexMakeMemoryPersistent(depStream);
	mexAtExit( &destKinect);
}


