function [lfp_wave center_freq] = wavetransform(aligned_trials,Fs)

%Input:
%      aligned_trials = array of truncated and aligned trials.  Assumes
%      rows are trials and columns are samples
%      Fs = sampling frequency
%Output :
%        lfp_wave = array of wave transformed trials, values are complex,
%        dimensions are ( frequency X time X trial)
%        center_freq = vector of peak frequencies corresponding to wavelet
%        scales

%function assumes that trials of interest have been pre-selected and
%truncated into an array (this appears to be what is being done, so I have
%stuck with it rather than quible). The intent is for this function to be run on each lfp of interest
% and the wavelet output to be converted to anaysis of interest in
% subsequent scripts.  In order to control for edge effects of the wave
% filter trials are padded and concatenated before being run through the
% transform, and then extracted back into an array.


%params for wavelet decomposition, hard codes might need tweaking
%later: Currently padding with half the trial and using scales for 2-150 hz, dropping scales for frequencies to low for
%window. complex morlet 1 -1 is a common wavelet, but in the future we
%could explore different bandwidths cmor or different wavelets

dims = size(aligned_trials);mid = ceil(dims(2)/2);
minfreq = Fs/dims(2)*5;
scales = 1./(10:10:750)*5000;scales = scales * Fs/1000; scales = fliplr(scales);
wave = 'cmor1-1';
ind = find(scal2frq(scales,wave,1/Fs) > minfreq);
scales = scales(ind);
center_freq = scal2frq(scales,wave,1/Fs);


%making padded LFP vector
lfp_pad = [fliplr(aligned_trials(:,1:mid)) aligned_trials fliplr(aligned_trials(:,mid+1:end))];
lfp_vect = reshape(lfp_pad',1,[]);

%wavelet transform
lfp_trans = cwt(lfp_vect,scales,wave);

%making freq decomposed trial array
wave_padded = reshape(lfp_trans,length(scales),[],dims(1));
lfp_wave = wave_padded(:,mid+1:mid+dims(2),:);



