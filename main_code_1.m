clc;
clear all;
close all;

% Parameters
fs = 128; % Sampling frequency
bands = [0.5 4; 4 8; 8 13; 13 30; 30 45]; % Delta, Theta, Alpha, Beta, Gamma bands
waveletType = 'db4'; % Wavelet type
level = 5; % DWT decomposition level

% Directory of CSV files
fileDir = 'E:\Polyspace\EEG LAB\Project\New folder\*.csv';
files = dir(fileDir);

% Initialize feature matrices and labels
featureMatrixBPF = [];
featureMatrixDWT = [];
labels = [];

for file = files'
    % Load data
    data = readmatrix(fullfile(file.folder, file.name));
    time = data(:, 1); % Assuming time is in the first column
    channels = data(:, 2:end); % EEG channels

    % Determine label based on last character in filename
    labelChar = file.name(end-4);
    if labelChar == '1'
        label = 0;
    elseif labelChar == '2'
        label = 1;
    else
        error('Unexpected file name format.');
    end
    
    % Segment the data into 10 parts
    numSegments = 10;
    segmentLength = floor(size(channels, 1) / numSegments);

    for seg = 1:numSegments
        segData = channels((seg-1)*segmentLength + 1 : seg*segmentLength, :);
        
        % Initialize feature vectors for each segment
        bpf_features = [];
        dwt_features = [];
        
        for ch = 1:size(segData, 2) % Iterate over each channel
            channelData = segData(:, ch);

            % BPF Feature Extraction
            bpf_features = [bpf_features, extract_bpf_features(channelData, fs, bands)];

            % DWT Feature Extraction
            dwt_features = [dwt_features, extract_dwt_features(channelData, waveletType, level)];
        end
        
        % Append features and labels to matrices
        featureMatrixBPF = [featureMatrixBPF; bpf_features];
        featureMatrixDWT = [featureMatrixDWT; dwt_features];
        labels = [labels; label];
    end
end

% Add labels to the feature matrices
featureMatrixBPF = [featureMatrixBPF, labels];
featureMatrixDWT = [featureMatrixDWT, labels];

% Save the feature matrices
writematrix(featureMatrixBPF, 'BPF_Features.csv');
writematrix(featureMatrixDWT, 'DWT_Features.csv');


% Function to compute Hjorth parameters
function hjorthParams = compute_hjorth_params(data)
    activity = var(data);
    mobility = sqrt(var(diff(data)) / activity);
    complexity = sqrt(var(diff(diff(data))) / var(diff(data)) / mobility);
    hjorthParams = [activity, mobility, complexity];
end

% Function to compute spectral entropy
function entropy = spectral_entropy(data, fs)
    psd = abs(fft(data)).^2; % Power spectral density
    psd = psd / sum(psd); % Normalize
    entropy = -sum(psd .* log(psd + eps)); % Spectral entropy
end

% Function to compute sample entropy
function sampEntropy = sample_entropy(data, m, r)
    N = length(data);
    count = 0;
    for i = 1:N-m
        for j = i+1:N-m
            if max(abs(data(i:i+m-1) - data(j:j+m-1))) < r
                count = count + 1;
            end
        end
    end
    sampEntropy = -log(count / (N-m));
end

% Function to compute differential entropy
function diffEntropy = differential_entropy(data)
    diffEntropy = 0.5 * log(2 * pi * exp(1) * var(data));
end

% Function for bandpass filtering
function filtered_data = bandpass_filter(data, lowcut, highcut, fs)
    [b, a] = butter(4, [lowcut highcut] / (fs / 2), 'bandpass');
    filtered_data = filtfilt(b, a, data);
end

% Function to extract features from BPF data
function features = extract_bpf_features(data, fs, bands)
    features = [];
    for b = 1:size(bands, 1)
        filtered_data = bandpass_filter(data, bands(b, 1), bands(b, 2), fs);
        
        % Compute features for each band
        mean_val = mean(filtered_data);
        sd_val = std(filtered_data);
        variance_val = var(filtered_data);
        skewness_val = skewness(filtered_data);
        kurtosis_val = kurtosis(filtered_data);
        hjorthParams = compute_hjorth_params(filtered_data);
        spectral_ent = spectral_entropy(filtered_data, fs);
        sample_ent = sample_entropy(filtered_data, 2, 0.2 * std(filtered_data));
        differential_ent = differential_entropy(filtered_data);

        % Append features for this band
        features = [features, mean_val, sd_val, variance_val, skewness_val, kurtosis_val, ...
                    hjorthParams, spectral_ent, sample_ent, differential_ent];
    end
end

% Function to extract features from DWT data
function features = extract_dwt_features(data, waveletType, level)
    [c, l] = wavedec(data, level, waveletType);
    features = [];
    
    % Approximation coefficients
    approx_coeff = appcoef(c, l, waveletType, level);
    features = [features, mean(approx_coeff), std(approx_coeff), var(approx_coeff), ...
                skewness(approx_coeff), kurtosis(approx_coeff), compute_hjorth_params(approx_coeff), ...
                spectral_entropy(approx_coeff, length(approx_coeff)), sample_entropy(approx_coeff, 2, 0.2 * std(approx_coeff)), ...
                differential_entropy(approx_coeff)];
    
    % Detail coefficients for each level
    for i = 1:level
        detail_coeff = detcoef(c, l, i);
        features = [features, mean(detail_coeff), std(detail_coeff), var(detail_coeff), ...
                    skewness(detail_coeff), kurtosis(detail_coeff), compute_hjorth_params(detail_coeff), ...
                    spectral_entropy(detail_coeff, length(detail_coeff)), sample_entropy(detail_coeff, 2, 0.2 * std(detail_coeff)), ...
                    differential_entropy(detail_coeff)];
    end
end
