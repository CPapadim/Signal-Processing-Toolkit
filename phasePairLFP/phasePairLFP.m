% Phase Pair LFP
%
%
% Output: 
%  LFP-LFP Pairwise Phase Consistency:  
%  


% Turn off warnings
warning off all

% Import Parameters from temp file
Params = readParams('Parameters.temp');


%%%%%%%%%%%%%%%%
% READ IN DATA %
%%%%%%%%%%%%%%%%

[AlignedLFPTrials1,LFPSamplingRate1,TrialType1,TrialStamps1,ExtractedReachTrialIndex1] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[AlignedLFPTrials2,LFPSamplingRate2,TrialType2,TrialStamps2,ExtractedReachTrialIndex2] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode2);

% Subtract out mean of each trial's LFP
AlignedLFPTrials1 = AlignedLFPTrials1 - repmat(mean(AlignedLFPTrials1,2),1,size(AlignedLFPTrials1,2));
AlignedLFPTrials2 = AlignedLFPTrials2 - repmat(mean(AlignedLFPTrials2,2),1,size(AlignedLFPTrials2,2));

% If the default start freq (-1) is passed, then only filter 60 Hz. 
if (Params.freqStart1 >= 0.5)
    freqStartTemp = max(Params.freqStart1-5,0.5);
    [AlignedLFPTrials1] = filterLfp(AlignedLFPTrials1,LFPSamplingRate1,Params.freqStart1,freqStartTemp,Params.freqEnd1,Params.freqEnd1+5);
    [AlignedLFPTrials2] = filterLfp(AlignedLFPTrials2,LFPSamplingRate2,Params.freqStart1,freqStartTemp,Params.freqEnd1,Params.freqEnd1+5);
else
    % TODO: This should be handled more elegantly.
    error('High pass filtering with cutoff less than 0.5 Hz is not supported.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  COMPUTE HILBERT TRANSFORMATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute coherence for each trial
for iTrial = 1:size(AlignedLFPTrials1,1);

    % Hilbert transform the lfp signal
    lfpHilbert1 = hilbert(AlignedLFPTrials1(iTrial,:));    
    lfpHilbert2 = hilbert(AlignedLFPTrials2(iTrial,:));    

    % Save angles - FOR PPC
    phaseArray(iTrial,:) = angle(lfpHilbert1)-angle(lfpHilbert2);
    trialArray(iTrial,:) = repmat(iTrial,[size(lfpHilbert1)]);
end

% Compute mean coherence for each trial type
% NOTE: Averaging may be wrong. Maybe remove angle and average the coherence magnitude. 
typelist       = unique(TrialType1); 
N              = arrayfun(@(x) sum(TrialType1==x),typelist);

% PPC
for iType = 1:length(typelist)
    phaseArray1   = phaseArray(TrialType1==typelist(iType),:);
    trialArray1   = trialArray(TrialType1==typelist(iType),:);
    ppcVal(iType) = ppc(phaseArray1(:).',trialArray1(:).');
end


%%%%%%%%%%%%%%%%
%  Data Output %
%%%%%%%%%%%%%%%%

% Write file
fid = fopen('PhasePairLFPData','w');
fprintf(fid, '%s\n', char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n',sprintf('%d ',typelist));
fprintf(fid,'%s\n',sprintf('%d ',N));
fprintf(fid,'%s\n',sprintf('%e ',ppcVal));
fclose(fid);
