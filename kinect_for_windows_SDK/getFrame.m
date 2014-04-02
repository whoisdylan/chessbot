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

minv = 10;
gcs = [2 1 2 ; 1 0 1 ; 2 1 2];
gcs = gcs / sum(gcs(:));
a_filt = conv2(single(a),single(gcs),'same');
a(a < minv) = a_filt(a < minv);

dep = a';
figure(2)
    imshow(rgb)
    hold on
    colormap(gray);
    
    
    hold on, h=imagesc(dep);
    
    set(h, 'AlphaData', 0.5*(dep > minv));
    
    hold off
    

end

