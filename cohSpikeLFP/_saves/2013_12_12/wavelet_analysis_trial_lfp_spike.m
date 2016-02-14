% wavelet analysis

%set up parameters, Larry needs to set up macro to pass unit for plexon
%read in data and preprocess


warning off all

%Import Parameters when not being used as function
fid=fopen('Parameters.temp');
commandline=textscan(fid,'%s',1,'delimiter','\n');
params=textscan(fid,'%s %s %s %f %f %f %f %f %f %f');
fclose(fid);

datadirectory=char(params{1});
trialfile=params{2};
spikefile=params{3};
time_interval=params{4};
time_start=params{5};
time_end=params{6};
filter_span=params{7};
electrode=params{8};
alpha_plex=params{9};



% SET DEFAULTS IF ARGUMENT DOESN'T EXIST
if exist('time_interval') == 0
    time_interval = 300;
 end
if exist('time_start') == 0
    time_start = -150.0;
 end
if exist('time_end') == 0
   time_end = 150.0;
 end

%%%%  Read in LFP data
[AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,ExtractedTrialStamps,ReachTrialIndex] = readAndProcessLFPData(datadirectory, commandline{1}, trialfile, time_interval, alpha_plex, electrode);
[AlignedSpikeTrials] = readAndProcessSpikeData(trialfile, spikefile, time_interval, LFPSamplingRate, alpha_plex, ReachTrialIndex);


%%% Do wavelet analysis for each trial type
tls = unique(ExtractedTrialType);
filename = strcat('waveletData');
fid = fopen(filename,'a');
fprintf(fid,'%s\n','Spike-triggered average of unit normalized complex wavelet vectors (synchrony)');
fprintf(fid,'  lfp channel %f\n', electrode);
fprintf(fid,'Freq  Cohere  Cohere_Angle  Sync  Sync_Angle  Pval  Type\n')

for i = 1:length(tls)
    idx = find(ExtractedTrialType == tls(i));
    [center_freq mag_img(:,:,i),phase_angle(:,:,i),phase_cohere(:,:,i) sta_phase_angle sta_mag spike_lfp_sync spike_lfp_cohere sync_pval coherence_angle] = wave_spec_and_spike(LFPSamplingRate*1000,AlignedLFPTrials(idx,:),AlignedSpikeTrials(idx,:));
    data = [center_freq' spike_lfp_cohere coherence_angle spike_lfp_sync sta_phase_angle sync_pval ones(length(center_freq),1)*tls(i)];
    fprintf(fid,'%.3f %.3f %.3f %.3f %.3f %.3f %1f\n',data');
    [h1] =  plot_wave_grams(mag_img(:,:,i),center_freq,0,LFPSamplingRate*1000,'mag',i);
    print(h1,'-dpsc2','-append','waveletPower.ps');
    [h1] =  plot_wave_grams(phase_angle(:,:,i),center_freq,0,LFPSamplingRate*1000,'phase',i);
    print(h1,'-dpsc2','-append','waveletPhase.ps'); 
    [h1] =  plot_wave_grams(phase_cohere(:,:,i),center_freq,0,LFPSamplingRate*1000,'cohere',i);
    print(h1,'-dpsc2','-append','waveletCohere.ps');
end
fclose(fid)
%mkdir output

% save the data in matlab format?
%save('saveletMatlab')

