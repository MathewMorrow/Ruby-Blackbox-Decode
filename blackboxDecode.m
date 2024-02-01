clc
clear all
close all
format('longg')
tic

% MATLAB is amorphous on type -- everything is stored as the type of the RHS on assignment unless directly addressing the element of an existing array of a particular type.
% There's no concept of defining the type of the field of a struct; it takes on the type of the object stored in it on assignment.

% File constants
endOfHeaderStr = "$$ end of header";

% Start of frame marker
sofMarker = 'SOF';
% File Size Estimate
megaByteSize = 1024^2;
preAllocBytes = megaByteSize*10;
headerBytesSize = 256;
SOFBytesSize = 3;
frameDataBytesSize = 40;
frameBytesSize = SOFBytesSize + frameDataBytesSize;

% Format of each frame
blackboxStruct = struct(...
    'TimeuS', zeros(1,preAllocBytes),...
    'gyroPitchRaw', zeros(1,preAllocBytes),...
    'gyroPitchFilt', zeros(1,preAllocBytes),...
    'gyroPitchSetpoint', zeros(1,preAllocBytes),...
    'gyroRollRaw', zeros(1,preAllocBytes),...
    'gyroRollFilt', zeros(1,preAllocBytes),...
    'gyroRollSetpoint', zeros(1,preAllocBytes),...
    'gyroYawRaw', zeros(1,preAllocBytes),...
    'gyroYawFilt', zeros(1,preAllocBytes),...
    'gyroYawSetpoint', zeros(1,preAllocBytes),...
    'pitchP', zeros(1,preAllocBytes),...
    'pitchI', zeros(1,preAllocBytes),...
    'pitchD', zeros(1,preAllocBytes),...
    'rollP', zeros(1,preAllocBytes),...
    'rollI', zeros(1,preAllocBytes),...
    'rollD', zeros(1,preAllocBytes),...
    'throttle', zeros(1,preAllocBytes),...
    'altitude', zeros(1,preAllocBytes),...
    'verticalSpeed', zeros(1,preAllocBytes)...
    );
blackboxData = blackboxStruct;

% Variables
% Log meta data
frameIndex = 0; % Stores the number of frames encoded in the file
numFrameFails = 0; % Stores the number of failed frames
% Scaling constants
gyroRatesScale = 1/20.0;
pidScale = 1/30000.0;
throttleScale = 1/1000;
altitudeScale = 1/100;  % This is causing int16 overflow!! Change scale to 1 max. Change in FC FW as well
verticalSpeedScale = 1;

%% Open the .txt file
fileToOpen = uigetfile('*.txt');
disp('Opening File')
[fileID, errmsg] = fopen(fileToOpen, "r", "s");
disp(errmsg);

% If file failed to open show error and abort
if fileID == -1
    error('Error opening file');
end

% Get file size

% fileInfo = dir(string(sprintf('\\flightforflight\\%s', fileToOpen)))
fileInfo = dir(fileToOpen)
fileSizeBytes = fileInfo.bytes;
fileSizeFramesEstimate = (fileSizeBytes - headerBytesSize) / frameBytesSize;

%% Read the header until the end of the file header

% Extract data from header
for i = 1:100
    % Read whole line of text
    line = fgetl(fileID);
    if ~isempty(line)
        % Check if that line matches end-of-header string
        isHeaderEnd = strcmp(line, endOfHeaderStr);
        if isHeaderEnd
            disp('Reached end of header file')
            break;
        else
            % Use textscan to read the first word
            headerData = strsplit(line);
            headerWord = headerData{1};
            switch headerWord
                case 'pitch_PID:'
                    pitchP = str2double(headerData{2});
                    pitchI = str2double(headerData{3});
                    pitchD = str2double(headerData{4});
                case 'roll_PID_gain:'
                    rollPIDgain = str2double(headerData{2});
                    rollP = pitchP*rollPIDgain;
                    rollI = pitchI*rollPIDgain;
                    rollD = pitchD*rollPIDgain;
                case 'yaw_PI:'
                    yawP = str2double(headerData{2});
                    yawI = str2double(headerData{3});
                case 'gyro_lpf1:'
                    gyro_lpf1 = str2double(headerData{2});
                case 'gyro_notch_hz:'
                    gyro_notch_hz = str2double(headerData{2});
                case 'gyro_notch_w:'
                    gyro_notch_w = str2double(headerData{2});
                case 'dterm_lpf1:'
                    dterm_lpf1 = str2double(headerData{2});
                case 'dterm_lpf2:'
                    dterm_lpf2 = str2double(headerData{2});
                case 'gyro_x_offset:'
                     gyro_x_offset = str2double(headerData{2});
                case 'gyro_y_offset:'
                     gyro_y_offset = str2double(headerData{2});
                otherwise
            end
        end
    end

    % If no match in 100 lines something went wrong with log
    if i == 100
        error("Could not find end of header = ABORT")
    end
end

%% Decode the raw binary data
displayDecode = waitbar(0, 'Decoding Flight Log');
disp('Starting File Data Import')
sofFound = 0;
charsSOF = [];
totalBytesRead = headerBytesSize;
while ~feof(fileID)

    % Find the start-of-frame marker
    charsSOF = [];
    while(sofFound == 0)
        currentChar = fread(fileID, 1, 'char');
        % Append the character to the data string
        charsSOF = [charsSOF, char(currentChar)];
        % Check if start-of-frame is present in the accumulated data
        if endsWith(charsSOF, sofMarker)
            sofFound = true;
        end
    end

    bytesRead = 0;
    % Read time (uS) uint32 value
    bytesRead = bytesRead + 4;
    TimeuS = fread(fileID, 1, 'uint32');
    % Read 12 uint16 values
    bytesRead = bytesRead + 2*18;
    gyroPitchRaw = fread(fileID, 1, 'int16');
    gyroPitchFilt = fread(fileID, 1, 'int16');
    gyroPitchSetpoint = fread(fileID, 1, 'int16');
    gyroRollRaw = fread(fileID, 1, 'int16');
    gyroRollFilt = fread(fileID, 1, 'int16');
    gyroRollSetpoint = fread(fileID, 1, 'int16');
    gyroYawRaw = fread(fileID, 1, 'int16');
    gyroYawFilt = fread(fileID, 1, 'int16');
    gyroYawSetpoint = fread(fileID, 1, 'int16');
    pitchP = fread(fileID, 1, 'int16');
    pitchI = fread(fileID, 1, 'int16');
    pitchD = fread(fileID, 1, 'int16');
    rollP = fread(fileID, 1, 'int16');
    rollI = fread(fileID, 1, 'int16');
    rollD = fread(fileID, 1, 'int16');
    throttle = fread(fileID, 1, 'uint16');
    altitude = fread(fileID, 1, 'int16');
    verticalSpeed = fread(fileID, 1, 'int16');

    % Done reading frame
    % Check emmediatly for the next start-of-frame
    nextSOF = [];
    for i = 1:length(sofMarker)
        %nextSOF = [fread(fileID, 1, 'char'), fread(fileID, 1, 'char'), fread(fileID, 1, 'char')];
        currentChar = fread(fileID, 1, 'char');
        nextSOF = [nextSOF, char(currentChar)];
    end

    % Check if start-of-frame is present in the accumulated data
    % Full frame read seemingly with no data drops - append to import
    if endsWith(nextSOF, sofMarker)
        totalBytesRead = totalBytesRead + bytesRead + SOFBytesSize;
        frameIndex = frameIndex + 1;
        % Set the start-of-frame flag so the next loop can skip
        sofFound = 1;
        % Append to import
        blackboxData.TimeuS(frameIndex) = TimeuS;
        blackboxData.gyroPitchRaw(frameIndex) = (gyroPitchRaw * gyroRatesScale);
        blackboxData.gyroPitchFilt(frameIndex) = (gyroPitchFilt * gyroRatesScale);
        blackboxData.gyroPitchSetpoint(frameIndex) = (gyroPitchSetpoint * gyroRatesScale);
        blackboxData.gyroRollRaw(frameIndex) = (gyroRollRaw * gyroRatesScale);
        blackboxData.gyroRollFilt(frameIndex) = (gyroRollFilt * gyroRatesScale);
        blackboxData.gyroRollSetpoint(frameIndex) = (gyroRollSetpoint * gyroRatesScale);
        blackboxData.gyroYawRaw(frameIndex) = (gyroYawRaw * gyroRatesScale);
        blackboxData.gyroYawFilt(frameIndex) = (gyroYawFilt * gyroRatesScale);
        blackboxData.gyroYawSetpoint(frameIndex) = (gyroYawSetpoint * gyroRatesScale);
        blackboxData.pitchP(frameIndex) = (pitchP * pidScale);
        blackboxData.pitchI(frameIndex) = (pitchI * pidScale);
        blackboxData.pitchD(frameIndex) = (pitchD * pidScale);
        blackboxData.rollP(frameIndex) = (rollP * pidScale);
        blackboxData.rollI(frameIndex) = (rollI * pidScale);
        blackboxData.rollD(frameIndex) = (rollD * pidScale);
        blackboxData.throttle(frameIndex) = (throttle * throttleScale);
        blackboxData.altitude(frameIndex) = (altitude * altitudeScale);
        blackboxData.verticalSpeed(frameIndex) = (verticalSpeed * verticalSpeedScale);

    % Issue with frame. Ignore it and set file pointer back and try again
    elseif ~feof(fileID)
        numFrameFails = numFrameFails+1;
        % Set the sofFound as false - next loop will have to find
        sofFound = 0;
        % Rewind to just before previous start-of-frame
        %
        % fseek(fileID, -bytesRead, 'cof');
    end

    if mod(totalBytesRead, 100) == 0
        waitbar(totalBytesRead/fileSizeBytes, displayDecode)
    end

end

%% Trim data
blackboxData.TimeuS = blackboxData.TimeuS(1,1:frameIndex);
blackboxData.gyroPitchRaw = blackboxData.gyroPitchRaw(1,1:frameIndex);
blackboxData.gyroPitchFilt = blackboxData.gyroPitchFilt(1,1:frameIndex);
blackboxData.gyroPitchSetpoint = blackboxData.gyroPitchSetpoint(1,1:frameIndex);
blackboxData.gyroRollRaw = blackboxData.gyroRollRaw(1,1:frameIndex);
blackboxData.gyroRollFilt = blackboxData.gyroRollFilt(1,1:frameIndex);
blackboxData.gyroRollSetpoint = blackboxData.gyroRollSetpoint(1,1:frameIndex);
blackboxData.gyroYawRaw = blackboxData.gyroYawRaw(1,1:frameIndex);
blackboxData.gyroYawFilt = blackboxData.gyroYawFilt(1,1:frameIndex);
blackboxData.gyroYawSetpoint = blackboxData.gyroYawSetpoint(1,1:frameIndex);
blackboxData.pitchP = blackboxData.pitchP(1,1:frameIndex);
blackboxData.pitchI = blackboxData.pitchI(1,1:frameIndex);
blackboxData.pitchD = blackboxData.pitchD(1,1:frameIndex);
blackboxData.rollP = blackboxData.rollP(1,1:frameIndex);
blackboxData.rollI = blackboxData.rollI(1,1:frameIndex);
blackboxData.rollD = blackboxData.rollD(1,1:frameIndex);
blackboxData.throttle = blackboxData.throttle(1,1:frameIndex);
blackboxData.altitude = blackboxData.altitude(1,1:frameIndex);
blackboxData.verticalSpeed = blackboxData.verticalSpeed(1,1:frameIndex);


close(displayDecode);
disp('Finished Data Import')
fprintf("Number of frames: %d\n", frameIndex);
fprintf("Number of failed frames: %d\n", numFrameFails);
fclose(fileID);
disp('File closed')

% Calculate other data from log file as needed
pitchPID =  blackboxData.pitchP + blackboxData.pitchI + blackboxData.pitchD;
rollPID =  blackboxData.rollP + blackboxData.rollI + blackboxData.rollD;

% Stop execution timer
fileDecodeTime = toc;
display(fprintf("File Import Time: %d seconds\n", fileDecodeTime));

%% Log statistic

% Time data
uSperS = 1000000;
timeS = zeros(1,frameIndex);
for i = 1:frameIndex
    timeS(i) = (blackboxData.TimeuS(i) - blackboxData.TimeuS(1))/uSperS; 
end
logDurationS = timeS(frameIndex) - timeS(1);

% Odd time jumps at log #1164 #1420 ~0.7384S and 0.900S
logdT = zeros(1,(frameIndex-1));
for i = 2:(frameIndex)
    logdT(i-1) = blackboxData.TimeuS(i) - blackboxData.TimeuS(i-1);
end


logInfo = struct(...
    'FileSize', fileSizeBytes, ...
    'Duration',  logDurationS, ...
    'NumFrames', frameIndex, ...
    'FailedFrames', numFrameFails, ...
    'DecodeTime', fileDecodeTime...
    )























