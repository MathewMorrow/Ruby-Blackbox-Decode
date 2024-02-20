%% Calculate step response for pitch
[stepResp, stepT] = PTstepcalc(blackboxData.gyroPitchSetpoint, blackboxData.gyroPitchFilt, sampleFrequency/1000, 1);

s = [];
s = stepResp;
stepPitch=mean(s);
stepTPitch = stepT;

%% Calculate step response for pitch
[stepResp, stepT] = PTstepcalc(blackboxData.gyroRollSetpoint, blackboxData.gyroRollFilt, sampleFrequency/1000, 1);

s = [];
s = stepResp;
stepRoll=mean(s);
stepTRoll = stepT;

%% Calculate step response for pitch
[stepResp, stepT] = PTstepcalc(blackboxData.gyroYawSetpoint, blackboxData.gyroYawFilt, sampleFrequency/1000, 1);

s = [];
s = stepResp;
stepYaw=mean(s);
stepTYaw = stepT;

%% Plot Step Response
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesColorOrder', [0.4,0.2,0.2]);

figure Name 'Step Responses'
subplot(3,1,1);
plot(stepTPitch, stepPitch)
grid on
ylim([0 1.5]);
xlim([0,500]);
yline(1, '--', 'LineWidth', 1, 'Color', 'black');
title('Step Response')
ylabel('Pitch Response', 'FontWeight', 'bold')

subplot(3,1,2);
plot(stepTRoll, stepRoll)
grid on
ylim([0 1.5]);
xlim([0,500]);
yline(1, '--', 'LineWidth', 1, 'Color', 'black');
ylabel('Roll Response', 'FontWeight', 'bold')

subplot(3,1,3);
plot(stepTYaw, stepYaw)
grid on
ylim([0 1.5]);
xlim([0,500]);
yline(1, '--', 'LineWidth', 1, 'Color', 'black');
ylabel('Yaw Response', 'FontWeight', 'bold')
xlabel('Time (ms)', 'FontWeight', 'bold')

