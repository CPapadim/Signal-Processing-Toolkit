% wavelet analysis

%set up parameters, Larry needs to set up macro to pass unit for plexon
%read in data and preprocess


% Turn off warnings
warning off all

%Import Parameters when not being used as function
Params = readParams('Parameters.temp');


%%%%  Read in LFP data
[AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,~,ReachTrialIndex] = readAndProcessLFPData(Params.datadirectory,Params.commandline{1},Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[AlignedSpikeTrials] = readAndProcessSpikeData(Params.trialfile,Params.spikefile,Params.timeInterval,LFPSamplingRate,Params.alphaPlex,ReachTrialIndex);


%%% Do wavelet analysis for each trial type
tls = unique(ExtractedTrialType);
filename = strcat('CohSpikeLFPData');
fid = fopen(filename,'a');
fprintf(fid,'%s\n',char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'\nFreq  Cohere  Cohere_Angle  Sync  Sync_Angle  Pval  Type\n')

for i = 1:length(tls)
    idx = find(ExtractedTrialType == tls(i));
    [center_freq mag_img(:,:,i),phase_angle(:,:,i),phase_cohere(:,:,i) sta_phase_angle sta_mag spike_lfp_sync spike_lfp_cohere sync_pval coherence_angle] = wave_spec_and_spike(LFPSamplingRate*1000,AlignedLFPTrials(idx,:),AlignedSpikeTrials(idx,:));
    data = [center_freq' spike_lfp_cohere coherence_angle spike_lfp_sync sta_phase_angle sync_pval ones(length(center_freq),1)*tls(i)];
    fprintf(fid,'%.3f %.3f %.3f %.3f %.3f %.3f %1d\n',data');
end
fclose(fid)
%
