function [ppcVals] = waveletPhase(fs,freqs,lfp,spike)

%%%%%%%%%%%%%
% PROCEDURE %
%%%%%%%%%%%%%

% Dimensional data from lfp signal
[nTrials,nSamples] = size(lfp);
minFreq    = fs/nSamples*5;
if any(freqs < minFreq)
    warning('Some frequencies have less than 5 cycles!!');
end

% Wavelet
wave = 'cmor1-1';

% Calculate scales
scales     = fs./freqs;

% Making padded LFP
mid	      = ceil(nSamples/2);
lfpPadded = [fliplr(lfp(:,1:mid)) lfp fliplr(lfp(:,mid+1:end))];

% Instantiate aggregates
phaseArray = [];
trialArray = [];

% Iterate through all trials
for iTrial = 1:nTrials

	% Wavelet Transformation
    wavePadded  = cwt(lfpPadded(iTrial, :), scales, wave);
	lfpWave     = wavePadded(:, mid+1:mid+nSamples);
    
    % Get phases at spikes
    trialPhases = angle(lfpWave(:,spike(iTrial,:)==1));

    % Aggregate phases for each trial
    phaseArray = [phaseArray,trialPhases];
    trialArray = [trialArray,iTrial*ones(1,size(trialPhases,2))];
end

% Get PPC statistics for each frequency
ppcVals = ppc(phaseArray,trialArray);
