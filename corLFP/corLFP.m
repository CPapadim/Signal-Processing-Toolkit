% CORRELATE LFPs 
%
% Output: 
%  LFP-LFP Correlations:  
%  
%  command line
%  parameters
%  N of each trial type
%  Correlation Array (2 x trial type), where the first dimension
%  denotes 1 - Correlation Coefficient, 2 - P Value
%

% Turn off warnings
warning off all

%Import Parameters when not being used as function
%[commandline, datadirectory, trialfile, spikefile, time_interval,Params.time_start, time_end, smoothdata, electrode1, electrode2, freq_start, freq_end, junk_freq_step, alpha_plex, junk_hemisphere,paramsstr] = readParams('Parameters.temp');
Params = readParams('Parameters.temp');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  READ IN  DATA               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AlignedLFPTrials1,LFPSamplingRate1,TrialType1] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[AlignedLFPTrials2,LFPSamplingRate2,TrialType2] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode2);

%  Filter Frequencies - Comment out if not filtering
% Subtracting the mean signal (evoked response) before doing correlation.
AlignedLFPTrials1 = AlignedLFPTrials1-repmat(mean(AlignedLFPTrials1,2),1,size(AlignedLFPTrials1,2));
AlignedLFPTrials2 = AlignedLFPTrials2-repmat(mean(AlignedLFPTrials2,2),1,size(AlignedLFPTrials2,2));

% If the default start freq (-1) is passed, then only filter 60 Hz. 
if (Params.freqStart1 >= 0.5)
    freqStartTemp = max(Params.freqStart1-5,0.5)
    [AlignedLFPTrials1] = filterLfp(AlignedLFPTrials1,LFPSamplingRate1,Params.freqStart1,freqStartTemp,Params.freqEnd1,Params.freqEnd1+5);
    [AlignedLFPTrials2] = filterLfp(AlignedLFPTrials2,LFPSamplingRate2,Params.freqStart1,freqStartTemp,Params.freqEnd1,Params.freqEnd1+5);
elseif (freq_start < 0)
    [AlignedLFPTrials1] = filterLfp(AlignedLFPTrials1,LFPSamplingRate1);
    [AlignedLFPTrials2] = filterLfp(AlignedLFPTrials2,LFPSamplingRate2);
else
    % TODO: This should be handled more elegantly.
    error('High pass filtering with cutoff between 0 and 0.5 Hz is not supported.');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  COMPUTE CORRELATIONS	%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Iterate through all trials. Calculate each trial's correlation.
for cc = 1:size(AlignedLFPTrials1,1);
	[r, pV]=corrcoef(AlignedLFPTrials1(cc,:), AlignedLFPTrials2(cc,:));
	rAll(cc)=r(1,2);
	pAll(cc)=pV(1,2);
end
zAll=atanh(rAll); % Fisher Z transform


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SORT BY TRIAL TYPE - START  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Iterate through each trial type - matlab iterates through columns in a list, not rows, so it needs to be size 1 x N
typelist=unique(TrialType1)';
N=[];
typecount=0;
for i=typelist
	typecount=typecount+1;
	zTypeMean(typecount)=mean(zAll(TrialType1==i));
	[hTypeMean, pTypeMean(typecount)]=ttest(zAll(TrialType1==i),0,0.05,'both');
	
	N=[N size(AlignedLFPTrials1(find(TrialType1==i),:),1)];

end
rTypeMean=tanh(zTypeMean); % Fisher Z untransform


%%%%%%%%%%%%%%%%
%  Data Output %
%%%%%%%%%%%%%%%%

fid=fopen('CorLFPData','w');
fprintf(fid, '%s\n', char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n',sprintf('%d ',typelist));
fprintf(fid,'%s\n',sprintf('%d ',N));
dataFormat='%10.20f';
rTypeMeanstr=[];
pTypeMeanstr=[];
for tt=1:length(typelist)
	rTypeMeanstr = [rTypeMeanstr num2str(rTypeMean(tt),dataFormat) ' '];
    pTypeMeanstr = [pTypeMeanstr num2str(pTypeMean(tt),dataFormat) ' '];
end
fprintf(fid,'%s\n',rTypeMeanstr);
fprintf(fid,'%s\n',pTypeMeanstr);
fprintf(fid,'\nTrialType\tR\tp\n');
fprintf(fid,'%d %10.20f %10.20f\n', [TrialType1 rAll.' pAll.']')
fclose(fid);
