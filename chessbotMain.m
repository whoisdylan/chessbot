
%init board
board = cell(8,8);
board(2,:) = repmat({'pawn'},1,8);
board(7,:) = repmat({'pawn'},1,8);
board(1,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(8,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(3:6,:) = repmat({'empty'},4,8);

% comment this out if you want compile time enabled.
%COMPILED_MEX_FILES = 1;
%KINECT_INITIALIZED = 1;

if(exist('COMPILED_MEX_FILES') ~= 1)
    % only compile once or your matlab will crash...
    disp ' You need to change these paths to your Kinect SDK file ' 
    cd kinect_for_windows_SDK
    mex '-IC:\Program Files\Microsoft SDKs\Kinect\v1.8\inc' ...
        '-LC:\Program Files\Microsoft SDKs\Kinect\v1.8\lib\amd64' ...
        '-lKinect10' -g kinectInteract.cpp
    cd ..
    COMPILED_MEX_FILES = 1;
else
    disp 'Compilation Phase Skipped!'
end


% init kinect

if(exist('KINECT_INITIALIZED') ~= 1)
    kinectInteract(0)
    KINECT_INITIALIZED = 1;
else
    disp 'Kinect Initialize Skipped!'
end

%wait for some kind of input to signal white has moved, then scan board and
%update board state
gameOver = false;
[transferFunction] = initBoard();
%I don't know how to enum in matlab so states: wait=0, playerMoving=1,
%playerDone=2
currState = 0;
[~, ~, totalCovered] = getBoard(transferFunction);
handPresent = false;
handThresh = 3000;

while (~gameOver)
    nextState = currState;
    switch currState
        %waiting for player to move
        case 0
            disp 'In state 0'
            tCovers = totalCovered;
            [currBoard, handPresent, totalCovered] = getBoard(transferFunction);
            %if hand is present, player is moving so don't update board
            if (handPresent || totalCovered > tCovers + handThresh)
                nextState = 1;
            else
                prevBoard = currBoard;
            end
        %player is moving
        case 1
            disp 'In state 1'
            [currBoard, handPresent, totalCovered] = getBoard(transferFunction);
            %if there's no hand, then the player is done moving so grab the
            %board
            if (~handPresent && totalCovered < tCovers + handThresh)
                nextState = 2;
                nextBoard = currBoard;
            end
        %player done moving
        case 2
            disp 'In state 2'
            %changeList should be cell array of the form {row col; newRow newCol} {pieceWasHere; nowHere}
            changeList = scanBoardForChanges(prevBoard, nextBoard);
            for i=1:size(changeList,1)
                oldRow = changeList(i,1);
                oldCol = changeList(i,2);
                newRow = changeList(i,3);
                newCol = changeList(i,4);
                if( newRow == 0 || newCol == 0)
                    disp 'No changes found!'
                    nextState = 0;
                    continue;
                end
                if(oldRow ~= 0 && oldCol ~= 0)
                    movedPiece = board(oldRow, oldCol);
                end
                %check if piece was captured
                displacedPiece = board(newRow, newCol);
                board(newRow, newCol) = movedPiece;
                
                if(oldRow ~= 0 && oldCol ~= 0)
                    board(oldRow, oldCol) = {'empty'};
                end
                %send movement commands to other chessbot
                if (~strcmp(displacedPiece,'empty'))
                    removePieceFromBoard(newRow, newCol);
                end
                if(oldRow ~= 0 && oldCol ~= 0)
                    movePiece(oldRow, oldCol, newRow, newCol);
                end
                %check for special cases
                if (newRow == 8 && strcmp(movedPiece, 'pawn'))
                    %if pawn reaches the end, replace with queen
                    board(newRow, newCol) = {'queen'};
                    replacePawnWithQueen(newRow, newCol);
                end
            end
            nextState = 0;
    end
    currState = nextState;
end