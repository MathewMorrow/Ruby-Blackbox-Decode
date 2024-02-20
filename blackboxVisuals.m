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

loopTimePercentError = zeros(1,frameIndex-1);
for k = 1:frameIndex-1
    loopTimePercentError(1,k) = 100*(1-logdT(1,k)/(2*317));
end

figure('Name', 'Log Rate Error %')
plot(loopTimePercentError);
title 'Log Rate Error %'
ylabel 'Log Rate Error (%)'
ylim([-100, 100])

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
title('Pitch Rate vs Time')
ylabel('Pitch Rate (degrees/s)')
xlabel('Time (s)')


figure('Name', 'Roll')
hold on
plot(timeS, blackboxData.gyroRollRaw, 'R');
plot(timeS, blackboxData.gyroRollFilt, 'B');
plot(timeS, blackboxData.gyroRollSetpoint, 'G');
hold off
legend('Raw', 'Filt', 'Set');
title('Pitch Rate vs Time')
ylabel('Pitch Rate (degrees/s)')
xlabel('Time (s)')


figure('Name', 'Yaw')
hold on
plot(timeS, blackboxData.gyroYawRaw, 'R');
plot(timeS, blackboxData.gyroYawFilt, 'B');
plot(timeS, blackboxData.gyroYawSetpoint, 'G');
hold off
legend('Raw', 'Filt', 'Set');
title('Pitch Rate vs Time')
ylabel('Pitch Rate (degrees/s)')
xlabel('Time (s)')


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
title(' Roll P,I,D Outputs vs Time')
ylabel('P,I,D outputs as motor throttle (%)')
xlabel('Time (s)')

%% Plot Roll PID total
figure('Name', 'Roll PID')
hold on
plot(timeS, rollPID);
hold off

%% Plot Altitude
figure('Name', 'Altitude')

subplot(2, 1, 1);
plot(timeS, blackboxData.altitude);
title 'Altitude (cm)'

subplot(2,1,2)
hold on 
plot(timeS, blackboxData.throttle);
plot(timeS, blackboxData.RcThrottle);
hold off
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

%% Plot All Speed
figure('Name', 'Vertical Speed')
hold on
plot(timeS, blackboxData.verticalSpeed);
plot(timeS, blackboxData.verticalSpeedAcc)
plot(timeS, blackboxData.verticalSpeedBaro)
hold off
legend('Vert Speed', 'Vert Speed Acc', 'Vert Speed Baro');

%% Plot Acceleration Z axis
figure('Name', 'Acceleration')
hold on
plot(timeS, blackboxData.AccZFiltered);
hold off
legend('Z-Axis');

%% Plot Altitude + Verticqal Speed
figure('Name', 'Altitude and Speed')

subplot(2, 1, 1);
plot(timeS, blackboxData.altitude);
title 'Altitude (cm)'

subplot(2,1,2)
hold on 
plot(timeS, blackboxData.verticalSpeed);
hold off
title 'Speed'

