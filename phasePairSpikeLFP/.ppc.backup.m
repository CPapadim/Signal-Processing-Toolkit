function [center_freq ppc_vals n_spike_all] = ppc(fs, lfp, spike)

% Dimensional data from lfp signal
[n_trials n_samples] = size(lfp);

% Wavelet
wave = 'cmor1-1';

% Calculate SCALES and CENTER_FREQ
scales      = fliplr(1./(10:10:750)*5000 * fs/1000);
minfreq     = fs/n_samples*5;
ind         = find(scal2frq(scales,wave,1/fs) > minfreq);
scales      = scales(ind);
center_freq = scal2frq(scales,wave,1/fs);

% Calculate number of spikes
n_spike_all = length(find(spike));

% Making padded LFP
mid	= ceil(n_samples/2);
lfp_pad	= [fliplr(lfp(:,1:mid)) lfp fliplr(lfp(:,mid+1:end))];

% Instantiate aggregates and aggregate index (I_AGG)
phase_array   = zeros(length(scales), n_spike_all);
trial_array   = zeros(1, n_spike_all);
%n_spike_array = zeros(1, n_spike_all);
i_agg         = 1;

for i_trial = 1:n_trials

	% Wavelet Transformation
	wave_padded = cwt(lfp_pad(i_trial, :), scales, wave);
	lfp_wave    = wave_padded(:, mid+1:mid+n_samples);
	
	% Calculate phase
	mag             = abs(lfp_wave);
	phase           = lfp_wave./ mag;
	phase(mag == 0) = 0;
    
	% Find indicies of where to record the phases from this trial in the aggregate arrays
	n_spike = sum(spike(i_trial, :)); 	
	i_aggs  = i_agg:(i_agg+n_spike-1);
		
	% Aggregate
	phase_array(:, i_aggs) = phase(:, spike(i_trial,:) == 1);
	trial_array(i_aggs)    = i_trial;
	%n_spike_array(i_aggs)  = n_spike;

	% Advance aggregation index
	i_agg = i_agg + n_spike;
end

[ppc_vals n_spike_all] = ppc_estimator(phase_array, trial_array);

return

% Calculate the number of trials with at least one spike
M = length(unique(trial_array));

% Compute phase-vector dot-products and pairwise-phase-consistency estimate
ppc_vals = zeros(length(scales),1);
dot_products_vec = zeros(1, n_spike_all);
pair_filter      = zeros(1, n_spike_all);
for i_freq = 1:length(scales)
	% Compute dot product of each phase-vector pair
    	phase_vector = phase_array(i_freq, :);
	norm_phase_vector = phase_vector ./ n_spike_array;	

	ppc_val = 0;
	for i = 1:length(phase_vector)
		dot_products_vec = real(norm_phase_vector .* conj(norm_phase_vector(i)));
		pair_filter      = trial_array ~= trial_array(i);

		ppc_val = ppc_val + sum(dot_products_vec.*pair_filter);
	end

	% Calcultate the ppc value for this frequency
	ppc_vals(i_freq) = ppc_val/(M*(M-1));
end
