function [ rgb,dep ] = getFrame( )
%GETFRAME Summary of this function goes here
%   Detailed explanation goes here

[b,a] = kinectInteract(1);
% for a demo overlay the images
c = uint8(zeros(480,640,3));
c(:,:,1) = (squeeze(b(3,:,:)))';
c(:,:,2) = (squeeze(b(2,:,:)))';
c(:,:,3) = (squeeze(b(1,:,:)))';
rgb = c;
dep = a';
end

