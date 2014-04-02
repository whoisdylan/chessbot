function [ rgb,dep ] = getFrame( )
%GETFRAME Summary of this function goes here
%   Detailed explanation goes here

[unalteredColor,unalteredDepth] = kinectInteract(1);
% for a demo overlay the images
rgb = uint8(zeros(480,640,3));
rgb(:,:,1) = (squeeze(unalteredColor(3,:,:)))';
rgb(:,:,2) = (squeeze(unalteredColor(2,:,:)))';
rgb(:,:,3) = (squeeze(unalteredColor(1,:,:)))';


dep = unalteredDepth';% conv2(single(unalteredDepth'),single(gaus),'same');
figure(2)
    imshow(rgb)
    hold on
    colormap(cool);
    
    
    hold on, h=imagesc(dep);
    
    set(h, 'AlphaData', 0.5*(dep > 0));
    
    hold off
    

end

