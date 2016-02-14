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
fprintf(fid,'%s\n','Pairwise Phase Consistency Estimates');
fprintf(fid,'  lfp channel %f\n', electrode);
fprintf(fid,'Freq  PPC  Type\n')

for i = 1:length(tls)
    idx = find(ExtractedTrialType == tls(i));
    [center_freq ppc_vals] = ppc(LFPSamplingRate*1000,AlignedLFPTrials(idx,:),AlignedSpikeTrials(idx,:));
    data = [center_freq(:) ppc_vals(:) ones(length(center_freq),1)*tls(i)];
    fprintf(fid,'%.3f %.3f %1f\n',data');
end
fclose(fid)
