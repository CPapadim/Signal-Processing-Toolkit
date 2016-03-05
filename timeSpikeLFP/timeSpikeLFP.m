% function spikeAvg( datadirectory, trialfile, time_interval, time_window, freq_start, freq_end, freq_step)
%
% Function parameters: directory of a data file, the name of a trial
%  file (stamp,time offset in ms,condition type), interval length (ms),
%  time window size (ms), start freq (Hz), end freq (Hz), freq window
%  step (Hz).
%
%
% Output: 
%  Spike Averaged LFP  (trial type x time x 2), where the last dimenion
%  denotes Spike Averaged LFP for each trial type (1) and Spike Averaged SD for each trial type (2)
%


% Turn off warnings
warning off all

%Import Parameters when not being used as function
Params = readParams('Parameters.temp');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  READ IN  DATA               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AlignedLFPTrials,LFPSamplingRate,TrialType,~,ExtractedReachTrialIndex] = readAndProcessLFPData(Params.datadirectory,Params.commandline,Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);
[AlignedTrialSpikes] = readAndProcessSpikeData(Params.trialfile,Params.spikefile,Params.timeInterval,LFPSamplingRate,Params.alphaPlex,ExtractedReachTrialIndex);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  COMPUTE SPIKE AVGD LFP      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[SpikeAvgdLFP] = spikeAvgLFPAnalysis(AlignedLFPTrials,LFPSamplingRate,AlignedTrialSpikes,Params.time1,Params.time2); 


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SORT BY TRIAL TYPE  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

typelist=unique(TrialType)'; %Iterate through each trial type - matlab iterates through columns in a list, not rows, so it needs to be size 1 x N
N=[];
typecount=0;
for i=typelist
	typecount=typecount+1;
	spikeAvgdSorted(typecount,:,1)=squeeze(nanmean(SpikeAvgdLFP(find(TrialType==i),:),1));
	spikeAvgdSorted(typecount,:,2)=squeeze(nanstd(SpikeAvgdLFP(find(TrialType==i),:),[],1));
	
	N=[N size(SpikeAvgdLFP(find(TrialType==i),:),1)];
end



%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Output		%
%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen('TimeSpikeLFPData','w');
fprintf(fid,'%s\n',char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n',sprintf('%d ',N));
dataFormat='%10.5f';
for p=1:size(spikeAvgdSorted,1)
      rowstrmean=[];
      rowstrsd=[];
      for tt=1:size(spikeAvgdSorted,2)
              if(tt<size(spikeAvgdSorted,2))
                      rowstrmean=[rowstrmean num2str(spikeAvgdSorted(p,tt,1),dataFormat) ' '];
                      rowstrsd=[rowstrsd num2str(spikeAvgdSorted(p,tt,2),dataFormat) ' '];
              else
                      rowstrmean=[rowstrmean num2str(spikeAvgdSorted(p,tt,1),dataFormat)];
                      rowstrsd=[rowstrsd num2str(spikeAvgdSorted(p,tt,2),dataFormat)];
              end
      end
      fprintf(fid,'%s\n',rowstrmean);
      fprintf(fid,'%s\n',rowstrsd);
end
fclose(fid);



%  end		% end of function
