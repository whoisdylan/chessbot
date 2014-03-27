%init board
board = cell(8,8);
board(2,:) = repmat({'pawn'},1,8);
board(7,:) = repmat({'pawn'},1,8);
board(1,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(8,:) = {'rook' 'knight' 'bishop' 'queen' 'king' 'bishop' 'knight' 'rook'};
board(3:6,:) = repmat({'empty'},4,8);

%wait for some kind of input to signal white has moved, then scan board and
%update board state

%changeList should be cell array of the form {row col; newRow newCol} {pieceWasHere; nowHere}

gameOver = false;
transferFunction = initBoard();
while (~gameOver)
    currentBoardImage = getBoard(transferFunction);
    if (whiteMoved)
        newBoardImage = getBoard(transferFunction);
        changeList = scanBoardForChanges(currentBoardImage, newBoardImage);
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
    elseif (myTurn)
        %accept commands from other chessbot to perform movements
    end
end