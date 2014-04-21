function moveRobot(motorNumber, speed, timeMS)
% send motor number (uint8), speed (int8), timeMS (uint16) 
% to arduino

% Input Ranges
% motorNumber 0 - 3 (Main Motors)
% speed -128 - 127 (Reverse is negative)
% timeMS (0 - 2^16)
validMotors = [0,1,2,3];
if(isempty(find(validMotors == motorNumber)))
    disp 'Invalid Motor Number!'
    return;
end



timeLowBits = bitand(uint16(timeMS),255);
timeHighBits = bitand(uint8(bitsra(uint16(timeMS),8)),255);

% send back a signal when it is finished

motorNumber = uint8(motorNumber);
speed = int8(speed);
timeLowBits = uint8(timeLowBits);
timeHighBits = uint8(timeHighBits);

% Displays the available serial ports on computer 
instrhwinfo('serial')

% should be changed depending on computer; COM3/4 is for windows
port = 'COM6';

ifs = instrfind;
if(~isempty(ifs))
    fclose(ifs);
end

global obj;
obj = serial(port, 'BaudRate', 9600, 'Parity', 'none', 'DataBits', 8, 'StopBits', 1,'Timeout',(timeMS + 1000)/1000);

% displays info of the port
get(obj,{'Type','Name','Port'})

fopen(obj);
pause(2);

fwrite(obj, motorNumber,'uint8');
fwrite(obj, speed,'int8');
fwrite(obj, timeLowBits,'uint8');
fwrite(obj, timeHighBits,'uint8');
disp 'Sent Command!'
str = fgets(obj);
disp(str);
%Wait however long the command is supposed to take
str = fgets(obj);
disp(str);

ifs = instrfind;
if(~isempty(ifs))
    fclose(ifs);
end
