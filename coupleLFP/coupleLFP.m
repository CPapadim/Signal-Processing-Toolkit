% Phase Amplitude Coupling LFP
%


% Turn off warnings
warning off all

% Import Parameters from temp file
Params = readParams('Parameters.temp');


%%%%%%%%%%%%%%%%
% READ IN DATA %
%%%%%%%%%%%%%%%%

% Load lfp trial data
[lfpAligned1,lfpSamplingRate1,trialType1] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[lfpAligned2,lfpSamplingRate2,trialType2] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode2);

% Subtract out mean of each trial's LFP
lfpCenter1 = lfpAligned1 - repmat(mean(lfpAligned1,2),1,size(lfpAligned1,2));
lfpCenter2 = lfpAligned2 - repmat(mean(lfpAligned2,2),1,size(lfpAligned2,2));

% Make sure the low cutoff freq is not too low.
if (any([Params.freqStart1,Params.freqStart2]<0.5))
    % TODO: This should be handled more elegantly.
    error('High pass filtering with cutoff less than 0.5 Hz is not supported.');
end

% Filter lfps
freqTemp1 = max(Params.freqStart1-5,0.5);
lfpFilt1  = filterLfp(lfpCenter1,lfpSamplingRate1,Params.freqStart1,freqTemp1,Params.freqEnd1,Params.freqEnd1+5);
freqTemp2 = max(Params.freqStart2-5,0.5);
lfpFilt2  = filterLfp(lfpCenter2,lfpSamplingRate2,Params.freqStart2,freqTemp2,Params.freqEnd2,Params.freqEnd2+5);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  COMPUTE HILBERT TRANSFORMATIONS %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute coherence for each trial
for iTrial = 1:size(lfpFilt1,1);

    % Hilbert transform the lfp signal
    lfpHilbert1 = hilbert(lfpFilt1(iTrial,:));    
    lfpHilbert2 = hilbert(lfpFilt2(iTrial,:));    

    % Save phase and amplitude for respective signals
    phaseArray(iTrial,:) = angle(lfpHilbert1);
    ampArray(iTrial,:)   = abs(lfpHilbert2); 
end

% Get types and number of trials per type
typelist = unique(trialType1); 
N        = arrayfun(@(x) sum(trialType1==x),typelist);

% Get mean vector length. Signal is defined by the amplitude of the second 
%   signal and the phase of the first signal.
signalArray = ampArray .* exp(1i*phaseArray);
for iType = 1:length(typelist)
    typeMatch = typelist==typelist(iType);
    meanVector(iType) = mean(mean(signalArray(typeMatch,:),2),1);
    meanPower(iType) = mean(mean(ampArray(typeMatch,:),2),1);
end
couplingVal = meanVector ./ meanPower;

% Permutation test
meanVectorPerm = NaN(length(typelist),100);
for iPerm = 1:100
    permIdx         = randperm(size(lfpAligned1,1));
    phaseArrayPerm  = phaseArray(permIdx,:);
    signalArrayPerm = ampArray .* exp(1i*phaseArrayPerm);
    for iType = 1:length(typelist)
        typeMatch = typelist==typelist(iType);
        meanVectorPerm(iType,iPerm) = mean(mean(signalArrayPerm(typeMatch,:),2),1);
    end
end

for iType = 1:length(typelist)
    couplingValPerm(iType,:) = meanVectorPerm(iType,:) / meanPower(iType);
    pPermTest(iType)         = mean(abs(couplingValPerm(iType,:)) > abs(couplingVal(iType)));
end


%%%%%%%%%%%%%%%%
%  Data Output %
%%%%%%%%%%%%%%%%

% Write file
fid = fopen('CoupleLFPData','w');
fprintf(fid, '%s\n', char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n',sprintf('%d ',typelist));
fprintf(fid,'%s\n',sprintf('%d ',N));
fprintf(fid,[sprintf('%e ',couplingVal),'\n']);
fprintf(fid,[sprintf('%e ',pPermTest),'\n']);
fclose(fid);
