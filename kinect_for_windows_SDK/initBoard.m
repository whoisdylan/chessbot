function [ tqf, bkg_dep ] = initBoard( color_image , dep)
%INITBOARD Take the current image from the kinect and use it
% to produce the warped board via clicking corners
    figure(5) % figure 5 is the initialize image
    imshow(color_image);
    gray_image = rgb2gray(color_image);
    %gray_image = color_image;
    title ('Click the corners of an EMPTY board');
    xlabel('Use order Top Left, Top Right, Bottom Right, Bottom Left');
    hold on
    xc = zeros(1,4);
    yc = zeros(1,4);
    for a = 1:4
        [x,y] = ginput(1);
        xc(a) = x;
        yc(a) = y;
        plot(x,y,'r.','MarkerSize',10);
        
    end
    
    title ('Click a point on the black side');
    xlabel('Place it in the middle of their area');
    [xb,yb] = ginput(1);
    plot(xb,yb,'kx','MarkerSize',100);
    
    title ('Click a point on the white side');
    [xw,yw] = ginput(1);
    plot(xw,yw,'wx','MarkerSize',100);
    hold off

    cds = [xc;yc];
    imgWid = 480;
    targs = [0 imgWid imgWid 0 ; 0 0 imgWid imgWid];
    
    
    tqf = cp2tform(cds',targs','projective');
    mod_img = imtransform(gray_image,tqf,'XData',[1,481],'YData',[1,481]);
    dep = imtransform(dep,tqf,'XData',[1,481],'YData',[1,481]);
    figure(4),imshow(mod_img)
    %{
    num_regions = 40;
    
    regions = length(dep) / num_regions;
    bkg_dep = zeros(num_regions);
    % find the mode of each of the blocks, 
    for i = 1:regions:(481 - regions)
        for j = 1:regions:(481 - regions)
            rgn = dep(i:(i+ regions),j:(j+regions));
            rgn(rgn == 0) = [];
            bkg_dep(round((i-1)/regions + 1),round((j-1)/regions + 1)) = mean(rgn(:));
        end
    end
    %}
    bkg_dep = 0;

end

