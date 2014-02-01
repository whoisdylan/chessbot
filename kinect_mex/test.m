
if ~(exist('kinect_mex')==3),
    fprintf('compiling the mex file... (probably need to change path names to get this to work!)\n');
    % NOTE probably need to change path names...
  mex  -I/usr/local/Cellar/libfreenect/0.2.0/include  -I/usr/local/include /usr/local/Cellar/libfreenect/0.2.0/lib/libfreenect.0.1.2.dylib /usr/local/Cellar/libusb/1.0.9/lib/libusb-1.0.0.dylib kinect_mex.cc
 
end


fprintf('Making first call to initalize the kinect driver and listening thread\n');
kinect_mex(); % call one to initialize the freenect interface
pause(2)
fprintf('Making second call starts getting data\n');
kinect_mex(); % get first data...


figure(1);
clf

fprintf('Press enter to see continuous frame grabbing\n');
pause;

tic;

   
last = toc;
draw_cum = 0;
draw_start = toc; draw_time=0;
for i=1:1000,
    [a,b]=kinect_mex();
    last = toc;
    fprintf('\r frame time = %4.4f  drawing_time = %4.4f',last-draw_start,draw_time);
    draw_start = toc;
    subplot(1,2,1);
    imagesc(permute(reshape(a,[640,480]),[2 1]))
    subplot(1,2,2);
    if (length(b)>307200),
        imagesc(permute(reshape(b,[3,640,480]),[3 2 1]))
    else
        imagesc(repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]))
    end
    drawnow
    draw_cum=draw_cum+toc-draw_start;
    draw_time=toc-draw_start;
end

fprintf('\n');
fprintf('Calling with two input params will get you the usage message\n');
kinect_mex(1,1); % get usage...

fprintf('Press enter to cycle through LED modes\n');
pause
kinect_mex('1');  pause
kinect_mex('2');  pause
kinect_mex('3');  pause
kinect_mex('4');  pause
kinect_mex('5');  pause
kinect_mex('0');  pause


fprintf('Press enter to cycle through video modes, starting with YUV_RGB\n');
pause
kinect_mex('Y');
for i=1:100,
    [a,b]=kinect_mex();
    subplot(1,2,1);
    imagesc(permute(reshape(a,[640,480]),[2 1]))
    subplot(1,2,2);
    if (length(b)>307200),
        imagesc(permute(reshape(b,[3,640,480]),[3 2 1]))
    else
        imagesc(repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]))
    end
    drawnow
end


fprintf('next will be the IR camera (press enter to see)\n');
pause
kinect_mex('I');
for i=1:10000,
    [a,b]=kinect_mex();
    subplot(1,2,1);
    imagesc(permute(reshape(a,[640,480]),[2 1]))
    subplot(1,2,2);
    if (length(b)>307200),
        imagesc(permute(reshape(b,[3,640,480]),[3 2 1]))
    else
        imagesc(repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]))
    end
    drawnow
end


fprintf('next will be RGB (press enter to see)\n');
pause
% there is some oddness here
kinect_mex('R');
[a,b]=kinect_mex();
pause(1)
kinect_mex('R');
[a,b]=kinect_mex();
pause(1)
kinect_mex('R');
[a,b]=kinect_mex();
pause(1)
kinect_mex('R');
[a,b]=kinect_mex();
pause(1)
for i=1:200,
    [a,b]=kinect_mex();
    subplot(1,2,1);
    imagesc(permute(reshape(a,[640,480]),[2 1]))
    subplot(1,2,2);
    if (length(b)>307200),
        imagesc(permute(reshape(b,[3,640,480]),[3 2 1]))
    else
        imagesc(repmat(permute(reshape(b,[640,480]),[2 1]),[1 1 3]))
    end
    drawnow
end

% keyboard

fprintf('tilting up...\n');
for i=1:40,
kinect_mex('w');
end

fprintf('tilting down...\n');
for i=1:100,
kinect_mex('x');
end

fprintf('leveling..\n');
kinect_mex('s');


fprintf('kinect_mex(''q'') stops the listening thread\n')

kinect_mex('q');

fprintf('done.  Have Fun!\n')



