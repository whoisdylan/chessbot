function moveToPosition( row, col)
    % 8 x 8 x 4, (In motor order 0, 1, 2 ,3)
    global PositionArray
    % Long that is the time it takes for any move
    global TIMEOUT
    % 1 x 4 Position for HOME
    global HOME

    % Always at HOME before Moving
    Bmov = [0 3 2 1];
    Hmov = [1 2 3 0];    
    if(row == 2)
        Bmov = [0 3 1 2];
        Hmov = [2 1 3 0];
    end
    % Preloaded piece
    
    if(row ~= 0 && col ~= 0)
        %pause(1);
        disp( ' Moving to Position! ' );
        
        for i = Bmov
            moveRobot(i,PositionArray(row,col,i + 1),TIMEOUT(i + 1));
         %   pause(1)
        end
        % Drop pre loaded piece
        moveClaw(2);
    else
        return;
    end
    
    disp( ' Returning Home! ');
    
    for i = Hmov
        moveRobot(i,HOME(i + 1),TIMEOUT(i+1));
        %pause(1)
    end
    
    disp( ' Load Next Piece' );
    pause(1);
    moveClaw(1);
    
    
    
end

