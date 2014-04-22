function [ boardState, handPresent, totalCovered ] = getBoard( transferFunction)
    % Requires tqf to be calculated via initBoard (transformation)

    [colorImage,depthImage] = getFrame();
    colorImage = imtransform(colorImage,transferFunction,'nearest','XData',[1,481],'YData',[1,481]);
    grayImage = rgb2gray(colorImage);
    grayImage = double(grayImage);
    grayImage = grayImage - min(grayImage(:));
    grayImage = grayImage/max(grayImage(:)) * 255;
    grayImage = uint8(round(grayImage));
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
    
    rgn = round(length(depthImage)/8); %size of single square
    rgnQuarter = round(rgn/8); %size of 1/4 of square
    pieceThresh = 20;
    detectPiece = 15;
    handThresh = 1500;
    boardState = zeros(8);
    boardMin = min(depthImage(:));
    handPresent = false;
    colorBlackThresh = 100;
    
    gaus = fspecial('gaussian',[5,5]);
    % find the total area of the covered region on the board.
    totalCovered = 0;
    
    for row=1:8
        for col=1:8
            region = depthImage(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
            zeroCount = conv2(double(region),gaus,'same') == 0;
            zeroCount = sum(zeroCount(:));
            
            original=region;
            region(region == 0) = [];
            
            if(length(region(:)) < length(original(:))*.25 ) 
                disp 'all NaNs in region '
                [row,col]
                boardState(row,col) = -1;
                handPresent = true;
                disp 'hand found'
                return;
            end
            
            maxDepth = double(max(region(:)));
            bct = double(sum(maxDepth - region(:) > pieceThresh));
            
            %return if hand is on board, player is moving
            %{
            if ((maxDepth - boardMin) > handThresh)
                handPresent = true;
                disp 'hand found'
                return;
            end
            %}
            totalCovered = totalCovered + bct + zeroCount;
            if (bct + zeroCount > detectPiece)
                grayRegion = grayImage(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
                midPoint = round(length(grayRegion) / 2);
                upperBound = round(midPoint + rgnQuarter);
                lowerBound = round(midPoint - rgnQuarter);
                graySubRegion = grayRegion(lowerBound:upperBound,lowerBound:upperBound);
%                 avgSubRegion = mean(graySubRegion,3);
                avgIntensity = mean(graySubRegion(:));
                if (avgIntensity <= colorBlackThresh)
                    %piece is black
                    boardState(row,col) = 1;
                else
                    %piece is white
                    boardState(row,col) = 2;
                end
            else
                %no piece
                boardState(row,col) = 0;
            end
        end
    end
    hold off
    figure(1)
    subplot(2,2,4)
    cla
    imagesc(boardState);
    pause(0.1)
end

