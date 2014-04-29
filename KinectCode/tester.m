if(exist('COMPILED_MEX_FILES') ~= 1)
    % only compile once or your matlab will crash...
    disp ' You need to change these paths to your Kinect SDK file ' 
    mex '-IC:\Program Files\Microsoft SDKs\Kinect\v1.8\inc' ...
        '-LC:\Program Files\Microsoft SDKs\Kinect\v1.8\lib\amd64' ...
        '-lKinect10' -g kinectInteract.cpp
    COMPILED_MEX_FILES = 1
end

% Enable Kinect
if(exist('KINECT_ENABLED') ~= 1)
    kinectInteract(0)
    KINECT_ENABLED = 1
end
[rgb,dep] = getFrame();
[tqf,modes] = initBoard(rgb,dep);
for i = 0:1000
tic

[rgb,dep] = getFrame();

    getBoard(tqf,rgb,dep,modes);
end

