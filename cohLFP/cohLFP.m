% COHERENCELFP
%
%
% Output: 
%  LFP-LFP Coherence:  
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

    % Compute cross spectra
    XY = lfpHilbert1 .* conj(lfpHilbert2);
    XX = lfpHilbert1 .* conj(lfpHilbert1);
    YY = lfpHilbert2 .* conj(lfpHilbert2);

    % Compute trial coherence
    coherence(iTrial) = mean(XY)/sqrt(mean(XX)*mean(YY));
end

% Fisher z-transform data
coherenceZ = atanh(abs(coherence)).*exp(1i*angle(coherence));

% Compute mean coherence for each trial type
% NOTE: Averaging may be wrong. Maybe remove angle and average the coherence magnitude. 
typelist       = unique(TrialType1); 
N              = arrayfun(@(x) sum(TrialType1==x),typelist);
coherenceMeanZ = arrayfun(@(x) mean(coherenceZ(TrialType1==x)),typelist);

% Fisher Z Un-Transform
coherenceMean = tanh(abs(coherenceMeanZ)).*exp(1i*angle(coherenceMeanZ));



%%%%%%%%%%%%%%%%
%  Data Output %
%%%%%%%%%%%%%%%%


% Write file
fid = fopen('CohLFPData','w');
fprintf(fid, '%s\n', char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,[sprintf('%d ',typelist),'\n']);
fprintf(fid,[sprintf('%d ',N),'\n']);
dataFormat='%10.20f';
fprintf(fid,'%s\n',sprintf([dataFormat,' '],abs(coherenceMean)));
fprintf(fid,'%s\n',sprintf([dataFormat,' '],rad2deg(angle(coherenceMean))));
fprintf(fid,'\n\nTrialType\tCoherence Mag\tCoherence Angle\n');
fprintf(fid,'%d %10.20f %10.20f\n', [TrialType1 abs(coherence).' rad2deg(angle(coherence)).']')

fclose(fid);
