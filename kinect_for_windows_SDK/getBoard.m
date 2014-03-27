function [ boardState ] = getBoard( transferFunction)
    % Requires tqf to be calculated via initBoard (transformation)

    [colorImage,depthImage] = getFrame();
    colorImage = imtransform(colorImage,transferFunction,'XData',[1,481],'YData',[1,481]);
    depthImage = imtransform(depthImage,transferFunction,'XData',[1,481],'YData',[1,481]);
    figure(4)
    imshow(colorImage)
    hold on
    colormap(jet);
    
    
    
    hold on, h=imagesc(depthImage);
    rgn = round(length(depthImage)/8);
    thresh = 100;
    boardState = zeros(8);
    for row=1:8
        for col=1:8
            region = depthImage(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
            region(region == 0) = NaN;
            mindep = min(region(:));
            maxdep = max(region(:));
            
            if(isnan(mindep) || isnan(maxdep)) 
                disp 'all NaNs in region '
                [row,col]
                
                continue;
            end
            boardState(row,col) = maxdep - mindep > thresh;
            
        end
    end
    
    set(h, 'AlphaData', 0.5*(depthImage > 0));
    
    hold off
    figure(3),imagesc(boardState);
    pause(0.1)
end

