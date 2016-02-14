function [center_freq ppc_vals] = ppc(fs, lfp, spike)

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
n_spike_array = zeros(1, n_spike_all);
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
	n_spike = length(find(spike(i_trial, :))); 	
	i_aggs  = i_agg:(i_agg+n_spike-1);
		
	% Aggregate
	phase_array(:, i_aggs) = phase(:, spike(i_trial,:) == 1);
	trial_array(i_aggs)    = i_trial;
	n_spike_array(i_aggs)  = n_spike;

	% Advance aggregation index
	i_agg = i_agg + n_spike;
end

% Make filter which ignores spikes from the same trial
[trial_X trial_Y] = meshgrid(trial_array);
pair_filter       = trial_X == trial_Y;

% Calculate normalization factor
[n_spike_X n_spike_Y] = meshgrid(n_spike_array);
NN                    = n_spike_X .* n_spike_Y;

% Calculate the number of trials with at least one spike
M = length(unique(trial_array));

% Compute phase-vector dot-products and pairwise-phase-consistency estimate
ppc_vals = zeros(length(scales),1);
for i_freq = 1:length(scales)
	% Compute dot product of each phase-vector pair
    [phase_X phase_Y]   = meshgrid(phase_array(i_freq,:));
    vector_dot_products = real(phase_X.*conj(phase_Y));

	% Calcultate the ppc value for this frequency
	ppc_vals(i_freq) = sum(sum(pair_filter.*vector_dot_products./NN./(M*(M-1))));
end
