% Created by Tarek Hamid
% hamidtarek3@gmail.com

% Initialize data
clear;
clc;
load("dataset_2.mat");

%% Plot sample of data by extracting one column

% Extract first column
sample_data = dataset_2(:,4);

% Look at sample data
sample_data = sample_data(2000:3000);

% Calculate time axis w/ sampling freq 17hz
fs = 17;
N = length(sample_data);
ts = 1/fs;
t = (0:N-1)*ts;

% Plot
figure(1);
plot(t,sample_data);
title('Plot of Sample Data');
xlabel('Time (s)');
ylabel('Magnitude');

%% Pre-processing - analyze frequency spectrum

% Compute fft and plot
fft_of_sample_data = abs(fft(sample_data));
figure(2)
subplot(2,1,1)
plot(fft_of_sample_data);
title('Frequency Analysis of Sample Data')
xlabel('Frequency')
ylabel('Magnitude')

% Compute with normalized frequency and plot
subplot(2,1,2)
plot([0:1/ (N/2 -1) :1], fft_of_sample_data(1:N/2));
title('(Normalized) Frequency Analysis of Sample Data')
xlabel('Frequency')
ylabel('Magnitude')

%% Pre-processing - low pass filtering / moving avg filter

% frequency domain - low pass Butterworth filter, 0.1 normalized freq cutoff
[b, a] = butter(5, 0.1, 'low');
filtered_sample_data = filter(b, a, sample_data);

% time domain - Moving avg filter
moving_avg_sample_data = movmean(sample_data, 10);
moving_avg_sample_data = movmean(moving_avg_sample_data, 10);
moving_avg_sample_data = movmean(moving_avg_sample_data, 5);

% Plot
figure(3);
subplot(3,1,1)
plot(t(50:end), sample_data(50:end));
title('Raw Respiration Signal')
xlabel('Time (s)')
ylabel('Magnitude')
subplot(3,1,2)
plot(t(50:end), filtered_sample_data(50:end));
title('Low Pass Filtered Respiration Signal')
xlabel('Time (s)')
ylabel('Magnitude')
subplot(3,1,3)
plot(t(50:end), moving_avg_sample_data(50:end));
title('Moving Avg Respiration Signal')
xlabel('Time (s)')
ylabel('Magnitude')

%% Algorithm 1 - peak detection with low pass filter

% Could also use find peaks fnc from MATLAB
% Can use mean of signal as baseline to decrease sensitivity
% Peak = sample greater than two nearest neighbors

% Initialize breath count in signal
low_pass_breath_count = 0;

% initialize respiration rates array
low_pass_filter_respiration_rates = [];

% initialize point where last breath was detected
previous_breath_timestamp = 0;
time_since_last_breath = 0;

% Iterate through signal. Compare neighbors and check if both less than
% current point. If yes -> add to breath count and add to respiration rate
% array
for i = 2 : length(filtered_sample_data) - 1
    if(filtered_sample_data(i) > filtered_sample_data(i - 1) && filtered_sample_data(i) > filtered_sample_data(i + 1))
        low_pass_breath_count = low_pass_breath_count + 1;
        time_since_last_breath = t(i) - previous_breath_timestamp;
        previous_breath_timestamp = t(i);
    end
    low_pass_filter_respiration_rates(end+1) = 60 / time_since_last_breath;
end

%% Algorithm 2 - peak detection with moving average filter

% Initialize breath count in signal
moving_avg_breath_count = 0;

% initialize respiration rates array
moving_avg_respiration_rates = [];

% initalize point where last breath was detected
previous_breath_timestamp = 0;
time_since_last_breath = 0;

% Traverse moving avg vector (same methodology as Algorithm 1).
breath_count = 0;
for i = 2 : length(moving_avg_sample_data) - 1
    if(moving_avg_sample_data(i) > moving_avg_sample_data(i - 1) && moving_avg_sample_data(i) > moving_avg_sample_data(i + 1))
        moving_avg_breath_count = moving_avg_breath_count + 1;
        time_since_last_breath = t(i) - previous_breath_timestamp;
        previous_breath_timestamp = t(i);
    end
    moving_avg_respiration_rates(end+1) = 60 / time_since_last_breath;
end

%% Plot respiration rates and calculate mean respiration rates

% Calculate mean low pass filtered respiration rate
duration_in_minutes = N / fs / 60;
mean_low_pass_respiration_rate = floor(low_pass_breath_count / duration_in_minutes);
display(mean_low_pass_respiration_rate);

% Calculate mean moving average respiration rate
mean_moving_avg_respiration_rate = floor(moving_avg_breath_count / duration_in_minutes);
display(mean_moving_avg_respiration_rate); 

% Plot respiration rates
figure(4)
subplot(2,1,1)
plot((linspace(0,t(end),length(low_pass_filter_respiration_rates))),low_pass_filter_respiration_rates)
title('Low Pass Filter Rates')
xlabel('Time (s)')
ylabel('Rate (breaths/min)')
subplot(2,1,2)
plot((linspace(0,t(end),length(moving_avg_respiration_rates))), moving_avg_respiration_rates)
title('Moving Avg Filter Rates')
xlabel('Time (s)')
ylabel('Rate (breaths/min)')