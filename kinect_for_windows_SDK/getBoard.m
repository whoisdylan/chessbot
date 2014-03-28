function [ boardState, handPresent ] = getBoard( transferFunction)
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
    pieceThresh = 100;
    handThresh = 2000;
    boardState = zeros(8);
    boardMin = min(depthImage(:));
    handPresent = false;
    for row=1:8
        for col=1:8
            region = depthImage(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
            region(region == 0) = NaN;
            minDepth = min(region(:));
            maxDepth = max(region(:));
            %return if hand is on board, player is moving
            if ((maxDepth - boardMin) > handThresh)
                handPresent = true;
                return;
            end
            if(isnan(minDepth) || isnan(maxDepth)) 
                disp 'all NaNs in region '
                [row,col]
                continue;
            end
            boardState(row,col) = maxDepth - minDepth > pieceThresh;
        end
    end
    
    set(h, 'AlphaData', 0.5*(depthImage > 0));
    
    hold off
    figure(3),imagesc(boardState);
    pause(0.1)
end

