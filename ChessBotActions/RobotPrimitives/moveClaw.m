function moveClaw(ACTION)
% send motor number (uint8), speed (int8), timeMS (uint16) 
% to arduino

% Input Ranges
% Action - 1 == CLOSE, 2 OPEN
if(ACTION ~= 1 && ACTION ~= 2)
   disp 'ACTION does not contain a valid value'
   return; 
end

motorNumber = 10;
speed = ACTION;

% send back a signal when it is finished

motorNumber = uint8(motorNumber);
speed = int8(speed);

% Displays the available serial ports on computer 
instrhwinfo('serial')

% should be changed depending on computer; COM3/4 is for windows
port = 'COM7';

ifs = instrfind;
if(~isempty(ifs))
    fclose(ifs);
end

global obj;
obj = serial(port, 'BaudRate', 9600, 'Parity', 'none', 'DataBits', 8, 'StopBits', 1,'Timeout',10);

% displays info of the port
get(obj,{'Type','Name','Port'})

fopen(obj);
pause(2);
% Writes the CLAW command and then ACTION then zeros
fwrite(obj, motorNumber,'uint8');
fwrite(obj, speed,'int8');
fwrite(obj, 0,'uint8');
fwrite(obj, 0,'uint8');
fwrite(obj, 0,'uint8');
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


