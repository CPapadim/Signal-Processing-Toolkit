function [ mag_img phase_angle phase_cohere] = wave_grams(lfp_wave,selected_trials)

%generates spectrograms (power by freq X time) and phase grams (phase by
%freq X time) from complex wavelet transform of trials,  averages across
%trials and displays the result

%Outputs:

%        mag_img = matrix used to generate power image
%        phase_angle = matrix of phases of summed transform
%        phase_cohere = matrix length summed vector/N trials


% Inputs:
%           lfp_wave = array of wavelet decompositions by trial dimensions
%           are (frequency X time X trial) values are complex transforms




% note: The phase map indicates whether the lfp at a specific frequnecy is phase 
% locked to the trial  variable used for alignment.  The magnitude image is a standard spectrogram,
% modulation of power with time by frequency. 
%%%%




%magnitude image:  normailizing by trial--need to get rid of 1/f and
%choosing to focus on within trial modulation in order to avoid noise from
%trials with higher or lower mean power

% magnitude and ormalizing
mag = abs(lfp_wave(:,:,selected_trials));
mag_mean = mean(lfp_wave(:,:,selected_trials),2);
mean_mag = repmat(mag_mean,1,size(lfp_wave(:,:,selected_trials),2),1);
mag_norm = (mag - mean_mag)./mean_mag;
%%%%%
%collapsing across trials, making the image
mag_img = mean(mag_norm,3);clear mag_norm mag_mean mean_mag



%phase image

phase = lfp_wave(:,:,selected_trials) ./ mag;
phase_mean = sum(phase,3);
phase_angle = angle(phase_mean);
phase_cohere = abs(phase_mean./length(selected_trials));


