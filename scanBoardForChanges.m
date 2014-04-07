function [ changeList ] = scanBoardForChanges(prevBoard, currBoard)
%takes in two binary board images, scans for changes on the board, outputs
%matrix of changes [row, col, newRow, newCol;...]
changeList=zeros(1,4);

boardDiff = prevBoard ~= currBoard;
% changes = boardDiff;
pieceMoves = currBoard(boardDiff) == 0;

[ci,cj] = ind2sub([8,8],find(boardDiff));
changes = [ci,cj];
piece0 = 1;
piece1 = 1;
for i=1:length(pieceMoves)
    %find which position is the old position and which is the new
    %by finding where there's no piece on the currBoardx
    if pieceMoves(i)
        changeList(piece0,1:2) = changes(i,:);
        piece0 = piece0 + 1;
    else
        changeList(piece1,3:4) = changes(i,:);
        piece1 = piece1 + 1;
    end
end

end

