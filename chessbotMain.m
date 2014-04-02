
%init board
board = cell(8,8);
board(2,:) = repmat({'pawn'},1,8);
board(7,:) = repmat({'pawn'},1,8);
board(1,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(8,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(3:6,:) = repmat({'empty'},4,8);

% comment this out if you want compile time enabled.
COMPILED_MEX_FILES = 1;
KINECT_INITIALIZED = 1;

if(exist('COMPILED_MEX_FILES') ~= 1)
    % only compile once or your matlab will crash...
    disp ' You need to change these paths to your Kinect SDK file ' 
    mex '-IC:\Program Files\Microsoft SDKs\Kinect\v1.8\inc' ...
        '-LC:\Program Files\Microsoft SDKs\Kinect\v1.8\lib\amd64' ...
        '-lKinect10' -g kinect_for_windows_SDK\kinectInteract.cpp
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

%changeList should be cell array of the form {row col; newRow newCol} {pieceWasHere; nowHere}

gameOver = false;
[transferFunction] = initBoard();
%I don't know how to enum in matlab so states: wait=0, playerMoving=1,
%playerDone=2
currState = 0;
handPresent = false;
while (~gameOver)
    nextState = currState;
    switch currState
        %waiting for player to move
        case 0
            [currBoard, handPresent] = getBoard(transferFunction);
            %if hand is present, player is moving so don't update board
            if (handPresent)
                nextState = 1;
            else
                prevBoard = currBoard;
            end
        %player is moving
        case 1
            [currBoard, handPresent] = getBoard(transferFunction);
            %if there's no hand, then the player is done moving so grab the
            %board
            if (~handPresent)
                nextState = 2;
                nextBoard = currBoard;
            end
        %player done moving
        case 2
            changeList = scanBoardForChanges(prevBoard, nextBoard);
            for i=1:2:size(changeList,1)/2
                oldRow = changeList(i,1);
                oldCol = changeList(i,2);
                newRow = changeList(i+1,1);
                newCol = changeList(i+1,2);
                movedPiece = board(oldRow, oldCol);
                %check if piece was captured
                displacedPiece = board(newRow, newCol);
                board(newRow, newCol) = movedPiece;
                board(oldRow, oldCol) = 'empty';
                %send movement commands to other chessbot
                if (~strcmp(displacedPiece,'empty'))
                    removePieceFromBoard(newRow, newCol);
                end
                movePiece(oldRow, oldCol, newRow, newCol);
                %check for special cases
                if (newRow == 8 && strcmp(movedPiece, 'pawn'))
                    %if pawn reaches the end, replace with queen
                    board(newRow, newCol) = 'queen';
                    replacePawnWithQueen(newRow, newCol);
                end
            end
            nextState = 0;
    end
    currState = nextState;
end