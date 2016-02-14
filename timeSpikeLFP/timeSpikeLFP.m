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


%%%%%FIGURES%%%%%
%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%% Spike Averaged LFP %%%%%%%%%%%%%%%%%%%%%%%%
%
%h=figure
%ystep=(time_end-time_start)/(size(spikeAvgdSorted,2)-1);
%typecount=0;
%for i=typelist
%	typecount=typecount+1;
%	hh(typecount)=subplot(length(typelist),1,typecount), plot((time_start:ystep:time_end),squeeze(spikeAvgdSorted(typecount,:,1)));
%	%set(gca,'XTick',[],'YTick',[]);
%end
%set(hh,'box','off');
%set(hh(1:end-1),'XColor',[0.99999999 0.99999999 0.99999999]); %PostScript doesn't seem to like printing pure white so using color close to white instead
%set(get(hh(end),'XLabel'),'String','Averaging Time Window (ms) - 0 ms is Spike Occurance');
%linkaxes(hh');
%set(h,'PaperPositionMode','auto','PaperSize',[100 100])
%print(h,'-dpsc2','-loose','-r1000','spikeAvgLFP.ps');
%
%
%h=figure;
%ystep=(time_end-time_start)/(size(spikeAvgdSorted,2)-1);
%linecolors=jet(length(1:(max(typelist)-min(typelist)+1)));
%coloridx=typelist-(min(typelist)-1);
%%linecolors=jet(length(min(typelist):max(typelist)));
%%coloridx=(1:length(min(typelist):max(typelist)));
%hold on;
%for pp=1:length(typelist);
%	plot((time_start:ystep:time_end),squeeze(spikeAvgdSorted(pp,:,1)),'Color',linecolors(coloridx(pp),:));
%end
%legendString = cellstr(num2str(typelist'));
%legend(legendString,'Location','EastOutside');
%title('Spike Avgd LFP');
%ylabel('LFP Signal');
%xlabel('Averaging Time Window (ms) - 0 ms is Spike Occurance'); 
%set(h,'PaperPositionMode','auto')
%print(h,'-dpsc2','-loose','-r600','-append','spikeAvgLFP.ps');
%
%
%h=figure;
%hold on
%plot(typelist,(squeeze(mean(abs(spikeAvgdSorted(:,:,1)),2))));
%scatter(typelist,(squeeze(mean(abs(spikeAvgdSorted(:,:,1)),2))));
%set(gca,'XTick',typelist);
%title('Spike Avgd LFP Tuning');
%ylabel('LFP Signal Mean');
%xlabel('Trial Type');
%set(h,'PaperPositionMode','auto')
%print(h,'-dpsc2','-loose','-r600','-append','spikeAvgLFP.ps');
%
%h=figure;
%ystep=(time_end-time_start)/(size(spikeAvgdSorted,2)-1);
%imagesc((time_start:ystep:time_end),1:length(typelist),squeeze(spikeAvgdSorted(:,:,1)));
%set(gca,'YTickLabel',typelist);
%colorbar
%title('Spike Avgd LFP');
%ylabel('Trial Type');
%xlabel('Averaging Time Window (ms) - 0 ms is Spike Occurance'); 
%set(h,'PaperPositionMode','auto')
%print(h,'-dpsc2','-loose','-r600','-append','spikeAvgLFP.ps');
%

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
