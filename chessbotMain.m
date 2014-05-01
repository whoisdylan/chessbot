
%init board
board = cell(8,8);
board(2,:) = repmat({'pawn'},1,8);
board(7,:) = repmat({'pawn'},1,8);
board(1,:) = {'rook' 'knight' 'bishop' 'king' 'queen' 'bishop' 'knight' 'rook'};
board(8,:) = {'rook' 'knight' 'bishop' 'king' 'queen' 'bishop' 'knight' 'rook'};
board(3:6,:) = repmat({'empty'},4,8);

% Add my files to the path pls!
addpath ('KinectCode','ChessBotActions','ChessBotActions/RobotPrimitives');
positionArray
% This will compile the code exactly once per run, you will have to restart
% matlab in order for this to not crash matlab if run twice, please don't
% run this twice :(
if(exist('COMPILED_MEX_FILES') ~= 1)
    % only compile once or your matlab will crash...
    disp ' You need to change these paths to your Kinect SDK file ' 
    cd KinectCode
    mex '-IC:\Program Files\Microsoft SDKs\Kinect\v1.8\inc' ...
        '-LC:\Program Files\Microsoft SDKs\Kinect\v1.8\lib\amd64' ...
        '-lKinect10' -g kinectInteract.cpp
    cd ..
    COMPILED_MEX_FILES = 1;
else
    disp 'Compilation Phase Skipped!'
end


% init kinect
% This will start the kinect, It will not crash Matlab, but if you call it
% too many times it will eat your memory and make the computer start
% running slowly, very slowly.
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
% 3400
handThresh = 5000;
averageCount = 0;
avMax = 10;
aveBoard = zeros(8,8,avMax);
disp 'Initializing board state'
for i = 1:avMax
    aveBoard(:,:,1:avMax - 1) = aveBoard(:,:,2:avMax);
    [aveBoard(:,:,avMax), handPresent, totalCovered] = getBoard(transferFunction); 
    
end
disp 'Ready for next move'
while (~gameOver)
    nextState = currState;
    switch currState
        %waiting for player to move
        case 0
            
            tCovers = totalCovered;
            aveBoard(:,:,1:avMax - 1) = aveBoard(:,:,2:avMax);
            [aveBoard(:,:,avMax), handPresent, totalCovered] = getBoard(transferFunction);
            %if hand is present, player is moving so don't update board
            if (handPresent || totalCovered > tCovers + handThresh)
                nextState = 1;
                disp 'Hand in Frame'
            else
                prevBoard = mode(aveBoard,3);
            end
        %player is moving
        case 1
            [currBoard, handPresent, totalCovered] = getBoard(transferFunction);
            %if there's no hand, then the player is done moving so grab the
            %board
            if (~handPresent && totalCovered < tCovers + handThresh)
                nextState = 2;
                nextBoard = currBoard;
                disp 'Scanning board for changes'
            end
        %player done moving
        case 2
            averageCount = averageCount + 1;
            [currBoard, handPresent, totalCovered] = getBoard(transferFunction);
            aveBoard(:,:,averageCount) = currBoard;
            if(averageCount == avMax)
                nextState = 3;
                disp 'Executing Changes'
            else
                nextState = 2;
            end
        case 3
            averageCount = 0;
            nextBoard = mode(aveBoard,3);
            %changeList should be cell array of the form {row col; newRow newCol} {pieceWasHere; nowHere}
            changeList = scanBoardForChanges(prevBoard, nextBoard);
            for i=1:size(changeList,1)
               
                oldRow = changeList(i,1);
                oldCol = changeList(i,2);
                newRow = changeList(i,3);
                newCol = changeList(i,4);
                if( newRow == 0 || newCol == 0 || oldRow == 0 || oldCol == 0)
                    disp 'No valid changes found!'
%                     nextState = 0;
                    continue;
                end
                movedPiece = board(oldRow, oldCol);

                %check if piece was captured
                displacedPiece = board(newRow, newCol);
                board(newRow, newCol) = movedPiece;
                board(oldRow, oldCol) = {'empty'};
                
                %send movement commands to other chessbot
                if (~strcmp(displacedPiece,'empty'))
                    removePieceFromBoard(newRow, newCol);
                end
                movePiece(oldRow, oldCol, newRow, newCol);
                %check for special cases
                if (newRow == 8 && strcmp(movedPiece, 'pawn') ||...
                    newRow == 1 && strcmp(movedPiece, 'pawn'))
                    %if pawn reaches the end, replace with queen
                    board(newRow, newCol) = {'queen'};
                    replacePawnWithQueen(newRow, newCol);
                end
                break;
            end
            %{
            % Uncomment for board state
            for i = 1:length(board)
                a = '';
                for j = 1:length(board)
                    a = sprintf('%s %s',a,board{i,j});
                end
                disp(a);
            end
            %}
            nextState = 0;
            disp 'Ready for next move'
    end
    currState = nextState;
end