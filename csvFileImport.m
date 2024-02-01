clc
close all
clear all


tempData = xlsread("matlabTestFlight.csv")

%% Analysis

micros = tempData(:,1);
timeSeconds = (tempData(:,1) - tempData(1:1)) / 1000000;
pitchRaw = tempData(:,8);
pitchFiltered = tempData(:,5);
pitchSetpoint = tempData(:,7);
    

figure
plot(timeSeconds,pitchRaw,"red")
hold on 
plot(timeSeconds,pitchFiltered,"blue")

Fs = 3158;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 32661;             % Length of signal
t = (0:L-1)*T;        % Time vector

fftDataRawPitch = fft(pitchRaw);
fftDataPitchFilterd = (pitchFiltered);

figure
plot(Fs/L*(0:L-1),abs(fftDataRawPitch),"LineWidth",3)
hold on 
plot(Fs/L*(0:L-1),abs(fftDataPitchFilterd),"LineWidth",3)

title("Complex Magnitude of fft Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")
xlim([0 1000])
ylim([0 10000])

sizeOfStepRespData = 20000;
pitchSetpointStepData = pitchSetpoint(1:20000);
pitchFilteredStepData = pitchFiltered(1:20000);

sysData = iddata(pitchSetpointStepData,pitchFilteredStepData, T );

% Estimate transfer function
sys = tfest(sysData, 1);
figure
step(sys)

% Simulate the model
t = 0:T:(T*(sizeOfStepRespData-1));        % time vector
y_est = lsim(sys, pitchSetpointStepData, t);

% Compare the simulated output with the actual output
figure;
%compare(pitchFilteredStepData, sys, y_est);
plot(pitchFilteredStepData,"blue");
hold on
plot(y_est, "red");
hold on
plot(pitchSetpointStepData, "yellow");
legend('Actual', 'Estimated');


