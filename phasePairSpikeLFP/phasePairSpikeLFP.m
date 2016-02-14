% wavelet analysis

%set up parameters, Larry needs to set up macro to pass unit for plexon
%read in data and preprocess


% Turn of warnings
warning off all

%Import Parameters when not being used as function
%[commandline, datadirectory, trialfile, spikefile, time_interval, time_start, time_end, filter_span, electrode, junk_electrode2, freq_start, freq_end, freq_step, alpha_plex, junk_hemisphere, paramsstr] = readParams('Parameters.temp');
Params = readParams('Parameters.temp');

%%%%  Read in LFP data
[AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,~,ReachTrialIndex] = readAndProcessLFPData(Params.datadirectory,Params.commandline{1},Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[AlignedSpikeTrials] = readAndProcessSpikeData(Params.trialfile,Params.spikefile,Params.timeInterval,LFPSamplingRate,Params.alphaPlex,ReachTrialIndex);

% Determine fres
freqs = Params.freqStart1:Params.freqStep1:Params.freqEnd1;

tls      = unique(ExtractedTrialType);
for i = 1:length(tls)
    idx = find(ExtractedTrialType == tls(i));
    N(i) = length(idx);

    % Wavelet-PPC estimates
    [ppcVals(:,i)] = waveletPPC(LFPSamplingRate*1000,freqs,AlignedLFPTrials(idx,:),AlignedSpikeTrials(idx,:));

end

% Creat output text file for wavelet-PPC results
filename = strcat('PhasePairSpikeLFPData');
fid      = fopen(filename,'w');
fprintf(fid,'%s\n',char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n\n',sprintf('%d ',N));
fprintf(fid,[repmat('%.10f ',[1,length(freqs)]) '\n'],ppcVals);

fclose(fid)
