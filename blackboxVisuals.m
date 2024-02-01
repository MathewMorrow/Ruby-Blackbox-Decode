close all

%% Plot Time Delta

figure('Name', 'Frame dT')
plot(timeS(1,2:frameIndex), logdT)
title 'Log deltaT'
xlabel 'Time (s)'
ylabel 'Log dT (uS)'

figure('Name', 'Time')
plot(timeS)
title 'Log Time'
xlabel 'Log Index'
ylabel 'Flight Time (s)'

%% Plot Raw Micros

figure('Name', 'TimeuS')
plot(blackboxData.TimeuS)
title 'Log Time uS'
xlabel 'Log Index'
ylabel 'Flight Time (us)'


%% Plot Gyro Data
figure('Name', 'Pitch')
hold on
plot(timeS, blackboxData.gyroPitchRaw, 'R');
plot(timeS, blackboxData.gyroPitchFilt, 'B');
plot(timeS, blackboxData.gyroPitchSetpoint, 'G');
hold off
xtickformat('%.2f')
legend('Raw', 'Filt', 'Set');


figure('Name', 'Roll')
hold on
plot(timeS, blackboxData.gyroRollRaw, 'R');
plot(timeS, blackboxData.gyroRollFilt, 'B');
plot(timeS, blackboxData.gyroRollSetpoint, 'G');
hold off
legend('Raw', 'Filt', 'Set');


figure('Name', 'Yaw')
hold on
plot(timeS, blackboxData.gyroYawRaw, 'R');
plot(timeS, blackboxData.gyroYawFilt, 'B');
plot(timeS, blackboxData.gyroYawSetpoint, 'G');
hold off
legend('Raw', 'Filt', 'Set');


%% Plot Pitch PID
figure('Name', 'Pitch P.I.D')
hold on
plot(timeS, blackboxData.pitchP);
plot(timeS, blackboxData.pitchI);
plot(timeS, blackboxData.pitchD);
hold off
legend('P', 'I', 'D');

%% Plot Pitch PID total
figure('Name', 'Pitch PID')
hold on
plot(timeS, pitchPID);
hold off

%% Plot Roll PID
figure('Name', 'Roll P.I.D')
hold on
plot(timeS, blackboxData.rollP);
plot(timeS, blackboxData.rollI);
plot(timeS, blackboxData.rollD);
hold off
legend('P', 'I', 'D');

%% Plot Roll PID total
figure('Name', 'Roll PID')
hold on
plot(timeS, rollPID);
hold off

%% Plot Altitude
figure('Name', 'Altitude')
% hold on
% plot(timeS, blackboxData.altitude);
% hold off

subplot(2, 1, 1);
plot(timeS, blackboxData.altitude);
title 'Altitude (cm)'

subplot(2,1,2)
plot(timeS, blackboxData.throttle);
title 'Throtte'

%% Plot Throttle
figure('Name', 'Throttle')
hold on
plot(timeS, blackboxData.throttle);
hold off
title 'Throttle'


%% Plot Vertical Speed
figure('Name', 'Vertical Speed')
hold on
plot(timeS, blackboxData.verticalSpeed);
hold off
legend('From Acc');

