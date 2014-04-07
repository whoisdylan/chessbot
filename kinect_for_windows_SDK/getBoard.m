function [ boardState, handPresent ] = getBoard( transferFunction)
    % Requires tqf to be calculated via initBoard (transformation)

    [colorImage,depthImage] = getFrame();
    colorImage = imtransform(colorImage,transferFunction,'nearest','XData',[1,481],'YData',[1,481]);
    depthImage = imtransform(depthImage,transferFunction,'nearest','XData',[1,481],'YData',[1,481]);
    %depthImage = averageBoard - double(depthImage);
    figure(1)
    subplot(2,2,3),
    imshow(colorImage)
    hold on
    colormap(cool);
    
    
    
    hold on, h=imagesc(depthImage);
    
    set(h, 'AlphaData', 0.5*(depthImage > 0));
    
    hold off
    
    rgn = round(length(depthImage)/8);
    pieceThresh = 30;
    detectPiece = 100;
    handThresh = 1500;
    boardState = zeros(8);
    boardMin = min(depthImage(:));
    handPresent = false;
    
    gaus = fspecial('gaussian');
    for row=1:8
        for col=1:8
            region = depthImage(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
            zeroCount = conv2(double(region),gaus,'same') == 0;
            zeroCount = sum(zeroCount(:));
            region(region == 0) = [];
            
            if(min(size(region)) == 0) 
                disp 'all NaNs in region '
                [row,col]
                boardState(row,col) = -1;
                continue;
            end
            
            minDepth = min(region(:));
            maxDepth = double(max(region(:)));
            bct = double(sum(maxDepth - region(:) > pieceThresh));
            
            %return if hand is on board, player is moving
            if ((maxDepth - boardMin) > handThresh)
                handPresent = true;
                disp 'hand found'
                return;
            end
            
            boardState(row,col) = bct + zeroCount > detectPiece;
        end
    end
    hold off
    figure(1)
    subplot(2,2,4)
    imagesc(boardState);
    pause(0.1)
end

