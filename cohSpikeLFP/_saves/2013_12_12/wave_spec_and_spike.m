function [center_freq mag_img phase_angle phase_cohere sta_phase_angle sta_mag spike_lfp_sync spike_lfp_cohere sync_pval coherence_angle] = wave_spec_and_spike(Fs, aligned_trials, spike)

% INPUT:     Fs = Sampling Frequency
%            aligned_trials = aligned LFP data as output from
%                  ReadAndPRocessLFP (Harry's code)
%            spike = Aligned spike data, expects binary, same sampling frequency as LFP, 0 no spike 1
%                 spike.  Harry's code will output this soon.  If no spike
%                 data is given the triggered average section is skipped and
%                 the sta outputs are zeros
%OUTPUT:       center_freq = center frequencies of the wavelets used in the analysis
%             mag_img = wavelet based spectrogram, focuses on modulation of power within a frequencies over a trial (normalized trial mean) units are percent
%             phase_angle = the angle of the complex vector sum of the transform, ignores length of the vector so does not indicate significance,
%                 utility is to see the phase at regions of significant coherence
%             phase_cohere = length of the summed normalized (unit length) complex vectors divided by number of trials,
%             ie a number between 0-1 showing the strength of the phase alignement across trials
%             Spike Triggered Average Variables, only relevant when spike data is passed.
%             sta_phase_angle = the angled of the the spike triggered sum of the complex vector,
%                 tells what angle syncrhony occurs at if it occurs (again, will have values even if synchrony is not significant)
%             sta_mag = spike triggered average of the power, not likely to show much unless spikes only occur if power is above or below mean
%             spike_lfp_sync = the synchrony between spike and lfp,  length of the unit vector sum, divided by number of spikes
%             spike_lfp_cohere = coherence between spike and lfp,  same as synchrony accept vectors are normalized, so amplitude weighted average
%             sync_pval = pvalue from the rayleigh distribution for the length of the summed unit vectors,
%                 liklihood that you could get a sum of the found length with a uniform distribution
%	      coherence_angle = angle of the coherence values in spike_lfp_cohere.

% OPERATION:  does continuous wavelet transform of supplied data, and spike triggered average of that if spikes passed.  Does not see trialtype:
% A for loop for trial type exists outside of this

%params for wavelet decomposition, hard codes might need tweaking
%later: Currently padding with half the trial and using scales for 2-150 hz, dropping scales for frequencies to low for
%window. complex morlet 1 -1 is a common wavelet, but in the future we
%could explore different bandwidths cmor or different wavelets

% If spikes are not passed to func, use an empty array as default
if nargin < 3
	spike = [];
else
	% If spikes are passed, verify spike and lfp are the same size.
	if not(size(spike) == size(aligned_trials))
		error('Mismatched spike and lfp sizes.');
	end
end

dims_sig = size(aligned_trials);mid = ceil(dims_sig(2)/2);
minfreq = Fs/dims_sig(2)*5;
scales = 1./(10:10:750)*5000;scales = scales * Fs/1000; scales = fliplr(scales);
% could update scales to take in F start stop and step, by multiplying
% scales start step and end by freq_start/2 freq_step/2 freq_stop/150
wave = 'cmor0.25-1';
ind = find(scal2frq(scales,wave,1/Fs) > minfreq);
scales = scales(ind);
center_freq = scal2frq(scales,wave,1/Fs);

%making padded LFP
lfp_pad = [fliplr(aligned_trials(:,1:mid)) aligned_trials fliplr(aligned_trials(:,mid+1:end))];

% Generating empty aggregators
mag_img = zeros(length(scales),dims_sig(2));
phase_mean = zeros(length(scales),dims_sig(2));
sta_mag = zeros(length(scales),1);
sta_phase = zeros(length(scales),1);
sta_mag_ss = zeros(length(scales),1);
sta_abs = zeros(length(scales),1);
sta_sum = zeros(length(scales),1);


for i = 1:dims_sig(1)
    %wavelet transform and extracting trials from padded data
    wave_padded = cwt(lfp_pad(i,:),scales,wave);
    lfp_wave = wave_padded(:,mid+1:mid+dims_sig(2));
    % magnitude and normalizing
    mag = abs(lfp_wave);
    mag_mean = mean(mag,2);
    mean_mag = repmat(mag_mean,1,size(mag,2));
    mag_norm = (mag - mean_mag)./mean_mag;
    %aggregating for magnitude (spectrogram) across trials
    mag_img = mag_img + mag_norm;clear mag_mean mean_mag
    
    
    %aggreting for phase/coherence across trials
    phase = lfp_wave./ mag;
    phase(mag == 0) = 0;
    phase_mean = phase_mean+phase;
    
    %spike triggered averaging (skip if spikes are not passed in).
    if (length(spike) > 0)
    	sta_mag = sta_mag+mean(mag_norm(:,spike(i,:)==1),2);
	sta_mag_ss = sta_mag_ss + sum(mag_norm(:,spike(i,:)==1).^2,2);
	sta_phase = sta_phase + sum(phase(:,spike(i,:)==1),2);
    	sta_abs = sta_abs +  sum(lfp_wave(:,spike(i,:)==1),2);
    	sta_sum = sta_sum + sum(mag(:,spike(i,:)==1),2);
    end
end

%Normalization, calculation of outputs
n = dims_sig(1);
mag_img = 100*mag_img/n;
phase_angle = angle(phase_mean);%phase_angle(phase_angle<0) = phase_angle(phase_angle<0)+2*pi;
phase_cohere = abs(phase_mean./n);
sta_phase_angle = angle(sta_phase);
sta_mag = sta_mag/n;
if (length(spike) > 0)
    nspike = length(find(spike));
else
    nspike = 1;
end
spike_lfp_sync = abs(sta_phase)/nspike;
spike_lfp_cohere = abs(sta_abs)./sta_sum;
coherence_angle = angle(sta_abs);
R = abs(sta_phase);
%Rayleigh test
sync_pval = exp(sqrt(1+4*nspike+4*((ones(length(scales),1)*nspike).^2-R.^2))-(1+2*nspike));
