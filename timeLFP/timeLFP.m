% WRITE LFP DATA
% Output: 
%	Writes out data
%

% Turn off warnings
warning off all


% Import parameters
Params = readParams('Parameters.temp');


%%%%%%%%%%%%%%%%%
% READ IN  DATA %
%%%%%%%%%%%%%%%%%

[AlignedLFPTrials,LFPSamplingRate,TrialType,~,ExtractedReachTrialIndex] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);

[AlignedTrialSpikes] = readAndProcessSpikeData(Params.trialfile,Params.spikefile,Params.timeInterval,LFPSamplingRate,Params.alphaPlex,ExtractedReachTrialIndex);


%%%%%%%%%%%%%%%
% Data Output %
%%%%%%%%%%%%%%%

% Write text file
fid = fopen('TimeLFPData','w');
fprintf(fid,'%s\n',char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%d\n',size(AlignedLFPTrials,1));
fprintf(fid,'%d\n',size(AlignedLFPTrials,2));
for iTrial = 1:size(AlignedLFPTrials,1)
    trialLineParams = sprintf('%d',TrialType(iTrial));
    trialLineSpikes = sprintf('%d ',AlignedTrialSpikes(iTrial,:));
    trialLineLFP    = sprintf('%d ',AlignedLFPTrials(iTrial,:));
    fprintf(fid,'%s\n',trialLineParams(1:end));
    fprintf(fid,'%s\n',trialLineSpikes(1:end-1));
    fprintf(fid,'%s\n',trialLineLFP(1:end-1));
end
fclose(fid);
