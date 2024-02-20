clc
clear all
close all

% const float setpointLpf = pt1FilterApply(&pidRuntime.windupLpf[axis], *currentPidSetpoint);
% const float setpointHpf = fabsf(*currentPidSetpoint - setpointLpf);

% itermRelaxFactor = MAX(0, 1 - setpointHpf / ITERM_RELAX_SETPOINT_THRESHOLD);


ITERM_RELAX_SETPOINT_THRESHOLD = 40;

numSamples = 1000;
setPoint = zeros(1,numSamples);


% float pt1FilterGain(float f_cut, float dT)
% {
%     float RC = 1 / (2 * M_PI * f_cut);
%     return dT / (RC + dT);
% }
f_cut = 15;
dT = 1/3200/2;
RC = 1 / (2 * pi * f_cut); 
pt1Gain = dT / (RC + dT);

% float pt1FilterApply(pt1Filter_t *filter, float input)
% {
%     filter->state = filter->state + filter->k * (input - filter->state);
%     return filter->state;
% }


%% Find step in log file

figure Name 'Find Step'
plot(blackboxData.gyroPitchSetpoint)

%% Step response tester

% [stepresponse, t] = PTstepcalc(SP, GY, lograte, Ycorrection)

[stepResp, stepT] = PTstepcalc(blackboxData.gyroPitchSetpoint, blackboxData.gyroPitchFilt, 1579/1000, 1);

                        s = [];
                        s = stepResp;
                        m=mean(s);

%% Plot Step Response
figure Name 'Step'
plot(stepT, m)
grid on


















