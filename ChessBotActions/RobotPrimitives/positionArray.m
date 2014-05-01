global PositionArray HOME TIMEOUT
PositionArray = zeros(8,8,4);
TIMEOUT = [10000 5000 5000 2000];
HOME = [237,685,791,425];
%maxTime = 7000 ms to go from left side to right side of board
% 2,3 2,4 2,5
% 3,3 3,4 3,5 
% 4,3 4,4 4,5
% 1,2
for i = 1:8
    for j = 1:8
        PositionArray(i,j,:) = HOME;
    end
end
PositionArray(1,1,:) = [724,680,567,368];
PositionArray(1,2,:) = [690,635,510,368];
%(1,3) = (660,
%(1,4) = (520

%(2,1) = (692,818,720,405)
%(2,2) = (660

% Do this
PositionArray(2,3,:) = [596, 639, 510, 368];
PositionArray(2,4,:) = [526, 610, 480, 368];
PositionArray(2,5,:) = [449, 610, 460, 368];


%(3,2) = (614, 639, 520, 360)
% These three
PositionArray(3,3,:) = [576, 750 ,665, 398];
PositionArray(3,4,:) = [526, 720, 650, 368];
PositionArray(3,5,:) = [466, 720, 650, 368];

%(4,1) = ignore
%(4,2) = ignore
% These Three
PositionArray(4,3,:) = [562, 835, 795,425];
PositionArray(4,4,:) = [524, 830, 780,425];
PositionArray(4,5,:) = [465, 835, 795,425];

%blackrook(1,8) = (278,689,567,369)
%blackpawn(1,7) = 
%blackknight(2,8) = (310,805,688,399)
%blackpawn(2,7) = 
%blackbishop(3,8) = 
%blackpawn(3,7) = 
%blackking(4,8) = 
%blackpawn(4,7) = 