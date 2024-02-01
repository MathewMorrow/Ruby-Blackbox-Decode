close all

%% Time Domain Stats
Fgyro = 3158;            % Gyro sampling frequency
SampleDivider = 2;
Fs = Fgyro/SampleDivider;
T = 1/Fs;               % Log Sampling period       
L = frameIndex;         % Length of signal
t = (0:L-1)*T;          % Time vector


%% Find Bounds of Frequency Domain that we care about

% Find data index for 60Hz - we only care about fft above this
index60Hz = 0;
fftFreq = Fs/L*(0:L-1); 
for i = 1:length(t)
    if fftFreq(i) > 60.0
        index60Hz = i;
        break;
    end
end
% Find data index for 500Hz - we only care about fft below this
index500Hz = 0;
fftFreq = Fs/L*(0:L-1); 
for i = index60Hz:length(t)
    if fftFreq(i) > 500.0
        index500Hz = i;
        break;
    end
end


%% FFT Pitch
fftgyroPitchRaw = fft(blackboxData.gyroPitchRaw);
fftgyroPitchFilt = fft(blackboxData.gyroPitchFilt);

fftgyroPitchRaw_MaxVal = 0;
for i = index60Hz:index500Hz
    if abs(fftgyroPitchRaw(i)) > fftgyroPitchRaw_MaxVal
        fftgyroPitchRaw_MaxVal = abs(fftgyroPitchRaw(i));
    end
end

figure('name', 'FFT Pitch')
hold on 
plot(Fs/L*(0:L-1),abs(fftgyroPitchRaw),"LineWidth",3)
plot(Fs/L*(0:L-1),abs(fftgyroPitchFilt),"LineWidth",3)
xline(gyro_lpf1, 'r--', 'LineWidth', 0.5, 'Label', 'Gyro LPF1');
xline(gyro_notch_hz, 'b--', 'LineWidth', 0.5, 'Label', 'Gyro Notch Fc');
xline(gyro_notch_hz - gyro_notch_w, 'b--', 'LineWidth', 0.25, 'Label', 'Gyro Notch +Wc');
xline(gyro_notch_hz + gyro_notch_w, 'b--', 'LineWidth', 0.25, 'Label', 'Gyro Notch -Wc');
xline(dterm_lpf1, 'g--', 'LineWidth', 0.5, 'Label', 'Dterm LPF1');
xline(dterm_lpf2, 'g--', 'LineWidth', 0.5, 'Label', 'Dterm LPF2');
hold off
title("Complex Magnitude of FFT Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")
xlim([0 700])
ylim([0 fftgyroPitchRaw_MaxVal*1.5])




%% FFT Roll
fftgyroRollRaw = fft(blackboxData.gyroRollRaw);
fftgyroRollFilt = fft(blackboxData.gyroRollFilt);

fftgyroRollRaw_MaxVal = 0;
for i = index60Hz:index500Hz
    if abs(fftgyroRollRaw(i)) > fftgyroRollRaw_MaxVal
        fftgyroRollRaw_MaxVal = abs(fftgyroRollRaw(i));
    end
end

figure('name', 'FFT Roll')
hold on 
plot(Fs/L*(0:L-1),abs(fftgyroRollRaw),"LineWidth",3)
plot(Fs/L*(0:L-1),abs(fftgyroRollFilt),"LineWidth",3)
xline(gyro_lpf1, 'r--', 'LineWidth', 0.5, 'Label', 'Gyro LPF1');
xline(gyro_notch_hz, 'b--', 'LineWidth', 0.5, 'Label', 'Gyro Notch Fc');
xline(gyro_notch_hz - gyro_notch_w, 'b--', 'LineWidth', 0.25, 'Label', 'Gyro Notch +Wc');
xline(gyro_notch_hz + gyro_notch_w, 'b--', 'LineWidth', 0.25, 'Label', 'Gyro Notch -Wc');
xline(dterm_lpf1, 'g--', 'LineWidth', 0.5, 'Label', 'Dterm LPF1');
xline(dterm_lpf2, 'g--', 'LineWidth', 0.5, 'Label', 'Dterm LPF2');
hold off
title("Complex Magnitude of FFT Spectrum")
xlabel("f (Hz)")
ylabel("|fft(X)|")
xlim([0 700])
ylim([0 fftgyroRollRaw_MaxVal*1.5])













