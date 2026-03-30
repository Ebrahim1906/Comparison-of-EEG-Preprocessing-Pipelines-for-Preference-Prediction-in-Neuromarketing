clc;
clear ;
filtered_data=importdata('041.csv');
m_data=filtered_data.data(:,2:17);
y=m_data';
[lenR,lenC]=size(y);
fs=128;
t=[0:(lenC)-1]/fs;
 
for i=1:1:16
    out(i,:)=bpf_filter(y(i,:),fs);
end
Delta_fp1=out(5).Delta;
Theta_fp1=out(5).Theta;
Alpha_fp1=out(5).Alpha;
Beta_fp1=out(5).Beta;
Gamma_fp1=out(5).Gamma;
% plot periodograms
figure;
[pxx_delta, f_delta] = periodogram(Delta_fp1, [], [], fs);
subplot(511); plot(f_delta, 10*log10(pxx_delta)); xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); title('Delta Power Spectrum');
 
[pxx_theta, f_theta] = periodogram(Theta_fp1, [], [], fs);
subplot(512); plot(f_theta, 10*log10(pxx_theta)); xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); title('Theta Power Spectrum');
 
[pxx_alpha, f_alpha] = periodogram(Alpha_fp1, [], [], fs);
subplot(513); plot(f_alpha, 10*log10(pxx_alpha)); xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); title('Alpha Power Spectrum');
 
[pxx_beta, f_beta] = periodogram(Beta_fp1, [], [], fs);
subplot(514); plot(f_beta, 10*log10(pxx_beta)); xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); title('Beta Power Spectrum');
[pxx_gamma, f_gamma] = periodogram(Gamma_fp1, [], [], fs);
subplot(515); plot(f_gamma, 10*log10(pxx_gamma)); xlabel('Frequency (Hz)'); ylabel('Power/Frequency (dB/Hz)'); title('Gamma Power Spectrum');