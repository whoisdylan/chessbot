function moveThePiece( orow, ocol, nrow,ncol)
    % 8 x 8 x 4, (In motor order 0, 1, 2 ,3)
    global PositionArray
    % Long that is the time it takes for any move
    global TIMEOUT
    % 1 x 4 Position for HOME
    global HOME

    % Always at HOME before Moving
    Bmov = [0 3 2 1];
    Hmov = [1 2 3 0];    
    if(orow == 2)
        Bmov = [0 3 1 2];
        Hmov = [2 1 3 0];
    end
    % Preloaded piece
    moveClaw(2);
    if(orow ~= 0 && ocol ~= 0)
        %pause(1);
        disp( ' Moving to Position! ' );
        
        for i = Bmov
            moveRobot(i,PositionArray(orow,ocol,i + 1),TIMEOUT(i + 1));
         %   pause(1)
        end
        % Grab piece
        moveClaw(1);
    else
        return;
    end
    
    disp( ' Returning Home! ');
    
    for i = Hmov
        moveRobot(i,HOME(i + 1),TIMEOUT(i+1));
        %pause(1)
    end
    
    % Always at HOME before Moving
    Bmov = [0 3 2 1];
    Hmov = [1 2 3 0];    
    if(nrow == 2)
        Bmov = [0 3 1 2];
        Hmov = [2 1 3 0];
    end
    if(nrow ~= 0 && ncol ~= 0)
        %pause(1);
        disp( ' Moving to Position! ' );
        
        for i = Bmov
            moveRobot(i,PositionArray(nrow,ncol,i + 1),TIMEOUT(i + 1));
         %   pause(1)
        end
        % release piece
        moveClaw(2);
    else
        return;
    end
    
    disp( ' Returning Home! ');
    
    for i = Hmov
        moveRobot(i,HOME(i + 1),TIMEOUT(i+1));
        %pause(1)
    end
    moveClaw(1);
    
    
    
end

