function [sta_mag sta_mag_std sta_phase spike_lfp_sync spike_lfp_cohere sync_pval] = spike_average_wave(lfp_wave,aligned_trial_spike,selected_trials)

% Input:
%       lfp_wave = wavelet output (freq X time X trial) complex value
%       aligned_trial_spike = matrix of binary vectors of spike occurance, one  row per trial
%       
% Output:  All are vectors over frequency
%         sta_mag = spike triggered average of lfp power modulation by freq
%        sta_mag_std = standard deviation of power  modulation across trials
%         sta_phase = spike triggered average of phase
%        spike_lfp_sync = phase of lfp by frequency independent of power at
%        time of spikes
%        spike_lfp_cohere = phase of lfp at spike times weighted by lfp
%        power
%        sync_pval = rayleigh test p value for spike lfp sync (and
%        sta_phase)  significance of the coherence is trickier, since the
%        vectors are of different lengths???

%    This script caluclates spike triggered averages of phase and power
%    modulation of an lfp signal.  Magnitude is normalized to be deviation
%    from the mean during a trial,  so the output, sta_mag, indicates
%    whether or not the power in a given band was on average above or below
%    the trial mean during the time of a spike,  in general this should
%    only really show if the trial caused lfp power enhancment or suppression in
%    a way related to the spike rate.  The phase calculations indicate
%    whether the lfp at a given frequency adopted a stable phase relative
%    to the trial timing across trials,  sync in this case referes to the
%    amplitude free relationship,  coherence to the amplitude weighted
%    relationship.

dims_sig = size(lfp_wave(:,:,selected_trials));
dims_spike = size(aligned_trial_spike(:,:,selected_trials));

mag = abs(lfp_wave(:,:,selected_trials));
mag_mean = mean(lfp_wave(:,:,selected_trials),2);
mean_mag = repmat(mag_mean,1,size(lfp_wave(:,:,selected_trials),2),1);
mag_norm = (mag - mean_mag)./mean_mag;
clear mag mag_mean mean_mag
if dims_sig(2) == dims_spike(2)
    spikes = squeeze(reshape(aligned_trial_spike(:,:,selected_trials)',[],1));
    mag_vect = reshape(mag_norm,dims_sig(1),[],1);
    phase_vect = squeeze(reshape(lfp_wave(:,:,selected_trials)./abs(lfp_wave(:,:,selected_trials)),dims_sig(1),[],1));
    wave_vect = squeeze(reshape(lfp_wave(:,:,selected_trials),dims_sig(1),[],1));
    sta_mag = mean(mag_vect(:,spikes),2);sta_mag_std = std(mag_vect(:,spikes),0,2);
    sta_phase = angle(sum(phase_vect(:,spikes),2));
    n = length(find(spikes));
    spike_lfp_sync = abs(sum(phase_vect(:,spikes),2))/n;
    spike_lfp_cohere = abs(sum(wave_vect(:,spikes),2))/n;
    R = abs(sum(phase_vect(:,spikes),2));
    sync_pval = exp(sqrt(1+4*n+4*((ones(dims_sig(1),1)*n).^2-R.^2))-(1+2*n));
end
    