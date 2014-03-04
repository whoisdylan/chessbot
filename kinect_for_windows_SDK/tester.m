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
for i = 0:1000
tic
[b,a] = kinectInteract(1);
% for a demo overlay the images
c = uint8(zeros(480,640,3));
c(:,:,1) = (squeeze(b(3,:,:)))';
c(:,:,2) = (squeeze(b(2,:,:)))';
c(:,:,3) = (squeeze(b(1,:,:)))';
figure(1)
imshow(c)
hold on
colormap(jet);
hold on, h=imagesc(a');
set(h, 'AlphaData', 0.5*(a' > 0));

a=toc;
ttl = sprintf('FPS: %d',uint8(1/a));
title(ttl);
hold off
pause(0.1)

end

