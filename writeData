function writeData(motorNumber, speed, timeLowBits, timeHighBits)
% send motor number (uint8), speed (int8), timeL (uint8), timeH (uint8) 
% to arduino 

% send back a signal when it is finished

motorNumber = uint8(motorNumber);
speed = int8(speed);
timeLowBits = uint8(timeLowBits);
timeHighBits = uint8(timeHighBits);

% Displays the available serial ports on computer 
instrhwinfo('serial')

% should be changed depending on computer; COM3/4 is for windows
port = 'COM3';

ifs = instrfind;
fclose(ifs);

global obj;
obj = serial(port, 'BaudRate', 9600, 'Parity', 'none', 'DataBits', 8, 'StopBits', 1);

% displays info of the port
get(obj,{'Type','Name','Port'})

fopen(obj);
pause(2);

fwrite(obj, motorNumber);
fwrite(obj, speed);
fwrite(obj, timeLowBits);
fwrite(obj, timeHighBits);
