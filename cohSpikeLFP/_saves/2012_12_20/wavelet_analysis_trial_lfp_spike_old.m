% wavelet analysis

%set up parameters, Larry needs to set up macro to pass unit for plexon
%read in data and preprocess

%%%% parameters taht are coming from larry
spikeAvg/spikeAvgLFP.m

warning off all


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

%Import Parameters when not being used as function
fid=fopen('Parameters.temp');
%commandline=textscan(fid,'%s',1);
params=textscan(fid,'%s %s %f %f %f %f %f %f','HeaderLines',1);
fclose(fid);

datadirectory=char(params{1});
trialtrialfile=params{2};
time_interval=params{3};
time_window=params{4};
freq_start=params{5};
freq_end=params{6};
freq_step=params{7};
alpha_plex=params{8};
electrode = 1; %hard set, no param yet


%%%% Waiting for Harry to finish spike import code  %%%%
%[AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,ExtractedTrialStamps] = readAndProcessData(datadirectory, trialfile, time_interval, alpha_plex, electrode)



for i = unique(ExtractedTrialType)
    idx = find(ExtractedTrialType == i);
    [center_freq mag_img phase_angle phase_cohere sta_phase_angle sta_mag spike_lfp_sync spike_lfp_cohere sync_pval ] = wave_spec_and_spike(Fs,AlignedLFPTrials(idx,:),AlignedSpikeTrials(idx,:))
    [h1] = plot_wave_grams(mag_img,center_freq,0,LFPSamplingRate,'mag',i);
end

