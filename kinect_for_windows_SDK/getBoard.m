function [ rgb, dep ] = getBoard( tqf, rgb, dep, bkg_dep)
    % Requires tqf to be calculated via initBoard (transformation)

    rgb = imtransform(rgb,tqf,'XData',[1,481],'YData',[1,481]);
    dep = imtransform(dep,tqf,'XData',[1,481],'YData',[1,481]);
    figure(4)
    imshow(rgb)
    hold on
    colormap(jet);
    
    
    
    hold on, h=imagesc(dep);
    rgn = round(length(dep)/8);
    thresh = 100;
    board = zeros(8);
    for row=1:8
        for col=1:8
            region = dep(((row-1)*rgn+1):row*rgn,((col-1)*rgn+1):col*rgn);
            region(region == 0) = NaN;
            mindep = min(region(:))
            maxdep = max(region(:))
            
            if(isnan(mindep) || isnan(maxdep)) 
                disp 'all NaNs in region '
                [row,col]
                
                continue;
            end
            board(row,col) = maxdep - mindep > thresh;
            
        end
    end
    
    set(h, 'AlphaData', 0.5*(dep > 0));
    
    hold off
    figure(3),imagesc(board);
    pause(0.1)
end

