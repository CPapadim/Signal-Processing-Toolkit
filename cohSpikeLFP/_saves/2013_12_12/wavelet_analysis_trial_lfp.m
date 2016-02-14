% wavelet analysis

%set up parameters, Larry needs to set up macro to pass unit for plexon
%read in data and preprocess



warning off all

%Import Parameters when not being used as function
fid=fopen('Parameters.temp');
commandline=textscan(fid,'%s',1);
params=textscan(fid,'%s %s %f %f %f %f %f %f %f','HeaderLines',1);
fclose(fid);

datadirectory=char(params{1});
trialfile=params{2};
time_interval=params{3};
time_window=params{4};
freq_start=params{5};
freq_end=params{6};
freq_step=params{7};
electrode=params{8};
alpha_plex=params{9};

% SET DEFAULTS IF ARGUMENT DOESN'T EXIST
if exist('time_interval') == 0
    time_interval = 500.0;
 end
if exist('time_window') == 0
   time_window = 200.0;
 end
if exist('freq_start') == 0
   freq_start = 30.0;
 end
if exist('freq_end') == 0
   freq_end = 60.0;
 end
if exist('freq_step') == 0
   freq_step = 10.0;
end

%%%%  Read in LFP data
[AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,ExtractedTrialStamps] = readAndProcessLFPData(datadirectory, trialfile, time_interval, alpha_plex, electrode);


%%% Do wavelet analysis for each trial type
tls = unique(ExtractedTrialType);

for i = 1:length(tls)
    idx = find(ExtractedTrialType == tls(i));
    [center_freq mag_img(:,:,i),phase_angle(:,:,i),phase_cohere(:,:,i) ] = wave_spec_and_spike(LFPSamplingRate,AlignedLFPTrials(idx,:));
    [h1] =  plot_wave_grams(mag_img(:,:,i),center_freq,0,LFPSamplingRate,'mag',i);
    print(h1,'-dpsc2','-append','power.ps');
    [h1] =  plot_wave_grams(phase_angle(:,:,i),center_freq,0,LFPSamplingRate,'phase',i);
    print(h1,'-dpsc2','-append','phase.ps'); 
    [h1] =  plot_wave_grams(phase_cohere(:,:,i),center_freq,0,LFPSamplingRate,'cohere',i);
    print(h1,'-dpsc2','-append','cohere.ps');
end

mkdir output
save output/wavelet_decomp_lfp

