% Created by Tarek Hamid
% hamidtarek3@gmail.com

% Initialize data
clear;
clc;
load("dataset_1.mat");

%% Plot sample of data by extracting one column

% Extract first column
sample_data = dataset_1(:,1);

% Look at first 1000 samples
sample_data = sample_data(1:1000);

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

%% Pre-processing - low pass filtering 

% 10th order low pass Butterworth filter, 0.1 normalized freq cutoff
[b, a] = butter(10, 0.1, 'low');
filtered_sample_data = filter(b, a, sample_data);
figure(3);
subplot(2,1,1)
plot(t, sample_data);
title('Raw Respiration Signal')
xlabel('Time (s)')
ylabel('Magnitude')
subplot(2,1,2)
plot(t, filtered_sample_data);
title('Filtered Respiration Signal')
xlabel('Time (s)')
ylabel('Magnitude')

%% Algorithm 1 - simple peak detection

% Can use mean of signal as baseline to decrease sensitivity

% Initialize breath count in signal
breath_count = 0;

% Iterate through signal. Compare neighbors and check if both less than
% current point. If yes -> add to breath count. 
% Peak = sample greater than two nearest neighbors
for i = 2 : length(filtered_sample_data) - 1
    if(filtered_sample_data(i) > filtered_sample_data(i - 1) && filtered_sample_data(i) > filtered_sample_data(i + 1))
        breath_count = breath_count + 1;
    end
end

% Calculate respiration rate
duration_in_minutes = N / fs / 60;
peak_detection_respiration_rate = floor(breath_count / duration_in_minutes);
display(peak_detection_respiration_rate);

%% Algorithm 2 - moving average filter 

% Use moving average filter to smooth data and ignore small transients.
moving_avg = movmean(filtered_sample_data, 7);

% Traverse moving avg vector (same methodology as Algorithm 1).
breath_count = 0;
for i = 2 : length(moving_avg) - 1
    if(moving_avg(i) > moving_avg(i - 1) && moving_avg(i) > moving_avg(i + 1))
        breath_count = breath_count + 1;
    end
end

% Calculate respiration rate
moving_avg_respiration_rate = floor(breath_count / duration_in_minutes);
display(moving_avg_respiration_rate);