function movePiece(oldRow, oldCol, newRow, newCol)
    str = sprintf('Moved piece from [%d,%d] to [%d,%d]',oldRow,oldCol,newRow,newCol);
    disp(str)
    tCol = newRow;
    tRow = newCol;
%    moveToPosition(tRow,tCol);
    
end

