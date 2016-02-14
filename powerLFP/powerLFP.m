% Power Macro
%
% Output: 
%  Power Matrix (trial type x freq x time x 2), where the last dimenion
%  denotes mean power for each trial type (1) and SD for each trial type (2)
%


% KNOWN ISSUES: 
%	If there is only one time point data is not properly broken up (it looks like there is a \n missing somewhere or something similar)

% Turn off warnings
warning off all

% Import Parameters
Params = readParams('Parameters.temp');

%commandline_args=regexp(char(commandline{1}),'\s+','split');
%
%%%  Extract Reach FileName %%
%slashes=strfind(char(commandline_args{end-1}),'/');
%if(isempty(slashes))
%        lastslash=1;
%else
%        lastslash=slashes(end);
%end
%reachfile=char(commandline_args{end-1}(lastslash+1:end));
%reachfullfile=char(commandline_args{end-1});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% SET DEFAULTS IF ARGUMENT DOESN'T EXIST
%if exist('time_interval') == 0
%    time_interval = 500.0;
% end
%if exist('time_window') == 0
%   time_window = 200.0;
% end
%if exist('freq_start') == 0
%   freq_start = 30.0;
% end
%if exist('freq_end') == 0
%   freq_end = 60.0;
% end
%if exist('freq_step') == 0
%   freq_step = 10.0;
% end
%if freq_step==0
%	freq_step=1;
%end

freq=Params.freqStart1:Params.freqStep1:Params.freqEnd1;
%time_step=double(round(time_window/4)); %Hardcode time step in spectral analysis to equal 1/4 of the time window
time_step=double(Params.time1)/4; %Hardcode time step in spectral analysis to equal 1/4 of the time window
%smoothspan=double(round(smoothSpan/time_step))
smoothspan=double(Params.filter/Params.timeInterval); % For lowess, span needs to be a fraction of total time


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  READ IN  DATA               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AlignedLFPTrials,LFPSamplingRate,TrialType] = readAndProcessLFPData(Params.datadirectory,Params.commandline{1},Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  COMPUTE THE POWER SPECTRUM  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[power_array]=powerSpectrum(AlignedLFPTrials,LFPSamplingRate,Params.time1,time_step,freq); %Generate Power Spectrum
%%% 	Normalize the Power Spectrum	%%%
%power_normalization=repmat(squeeze(mean(mean(power_array,1),3)),[size(power_array,1),1,size(power_array,3)]); %Normalize Power array by the mean value of each trial and time, for each frequency band - ONLY USED IN DEFAULT FIGS.
%power_array_normalized=power_array./power_normalization;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  SORT BY TRIAL TYPE - START  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

typelist=unique(TrialType)'; %Iterate through each trial type - matlab iterates through columns in a list, not rows, so it needs to be size 1 x N
N=[];
typecount=0;
for i=typelist
	typecount=typecount+1;
	
	powerSorted(typecount,:,:,1)=squeeze(mean(power_array(find(TrialType==i),:,:),1));
	powerSorted(typecount,:,:,2)=squeeze(std(power_array(find(TrialType==i),:,:),[],1));
	
	%powerSortedNorm(typecount,:,:,1)=squeeze(mean(power_array_normalized(find(TrialType==i),:,:),1));
	%powerSortedNorm(typecount,:,:,2)=squeeze(std(power_array_normalized(find(TrialType==i),:,:),[],1));
	
	N=[N size(power_array(find(TrialType==i),:,:),1)];
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%  Smooth the power spectrum 		% 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%-- Only smooths non-normalized data writen to files, NOT normalized data used in default figures --%
	%-- NOTE:  Currently does not work.  For loess smoothspan needs to be a fraction of total data -
	%-- (DONE BUT TEST),  										  --%
	%-- also, xvector and power_arrayTTF(:) need to be checked to make sure the appropriate values    --%
	%-- match up when smoothing.									  --%
	
		if(smoothspan>0)
			for ff=1:size(power_array,2)
				idxvector=find(TrialType==i);
				for ii = 1:length(idxvector)
					power_arrayTTF=squeeze(power_array(idxvector(ii),ff,:));
					xvector=[1:length(power_arrayTTF) 1:length(power_arrayTTF) 1:length(power_arrayTTF)];
					%xvector=[];
					%for tm=1:size(power_arrayTTF,3) %Loop through time
					%		xvector=[xvector; tm*(ones(size(power_arrayTTF,1)*size(power_arrayTTF,2),1))];
					%end
					tmparray=smooth(xvector,[fliplr(squeeze(power_arrayTTF)); squeeze(power_arrayTTF); fliplr(squeeze(power_arrayTTF))]',smoothspan,'loess'); %rloess gives weird results - test it.
					
					power_array(idxvector(ii),ff,:)=tmparray((1/3).*length(tmparray)+1:(2/3).*length(tmparray));
				end
			end
			powerSorted(typecount,:,:,1)=squeeze(mean(power_array(find(TrialType==i),:,:),1));
		end
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
%  SORT BY TRIAL TYPE - END   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                     FIGURES                      %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%% Power - Frequency vs. Time %%%%%%%%%%%%%%%%%%%%%%%%
%h=figure;
%power_means=squeeze(mean(power_array_normalized,1));
%imagesc(((time_window/2):time_step:(time_interval-time_window/2)),freq,power_means);
%freqstep=floor(length(freq)/10);
%if(freqstep>0)
%	set(gca,'YTick',freq(1:freqstep:end));
%	set(gca,'YTickLabel',freq(1:freqstep:end));
%else
%	set(gca,'YTick',freq);
%	set(gca,'YTickLabel',freq);
%end
%colorbar
%title('Normalized Power :::  Frequency vs. Time');
%ylabel('Frequency (Hz)');
%xlabel('Time (ms)');
%print(h,'-dpsc2','-loose','power.ps');
%
%%%%%%%%%%%%% Power - Trial Type vs. Time %%%%%%%%%%%%%%%%%%%%%%%%
%h=figure;
%pt_means=squeeze(mean(powerSortedNorm(:,:,:,1),2));
%imagesc(((time_window/2):time_step:(time_interval-time_window/2)),1:length(typelist),pt_means);
%set(gca,'YTick',1:length(typelist));
%set(gca,'YTickLabel',typelist);
%colorbar
%title('Normalized Power ::: Trial Type vs Time');
%ylabel('Trial Type');
%xlabel('Time (ms)');
%print(h,'-dpsc2','-loose','-append','power.ps');
%
%%%%%%%%%%%%% Power vs. Trial Type %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%h=figure;
%ptf_means=squeeze(mean(mean(powerSortedNorm(:,:,:,1),2),3));
%plot(typelist,ptf_means,'-o','LineWidth',5,'MarkerSize',10,'MarkerFaceColor','k');
%set(gca,'XTick',typelist);
%title('Mean Power vs. Trial Type');
%xlabel('Trial Type');
%ylabel('Power');
%print(h,'-dpsc2','-loose','-append','power.ps');
%

%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Output		%
%%%%%%%%%%%%%%%%%%%%%%%%%

%save('PowerOutput.mat','power_array','TrialType'); % Output single trial info as binary file.
fid=fopen('PowerData','w');
fprintf(fid,'%s\n',char(Params.commandline{1}));
fprintf(fid,'%s\n',Params.paramsstr);
fprintf(fid,'%s\n',sprintf('%d ',N));
dataFormat='%10.5f';
for p=1:size(powerSorted,1)
	for ff=1:size(powerSorted,2)
		rowstrmean=[];
		rowstrsd=[];
		for tt=1:size(powerSorted,3)
			if(tt<size(powerSorted,3))
				rowstrmean=[rowstrmean num2str(powerSorted(p,ff,tt,1),dataFormat) ' '];
				rowstrsd=[rowstrsd num2str(powerSorted(p,ff,tt,2),dataFormat) ' '];
			else
				rowstrmean=[rowstrmean num2str(powerSorted(p,ff,tt,1),dataFormat)];
				rowstrsd=[rowstrsd num2str(powerSorted(p,ff,tt,2),dataFormat)];
			end
		end
		fprintf(fid,'%s\n',rowstrmean);
		fprintf(fid,'%s\n',rowstrsd);
	end
end
fclose(fid);

%  end		% end of function
