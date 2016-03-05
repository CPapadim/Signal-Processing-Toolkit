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


freq=Params.freqStart1:Params.freqStep1:Params.freqEnd1;
time_step=double(Params.time1)/4; %Hardcode time step in spectral analysis to equal 1/4 of the time window
smoothspan=double(Params.filter/Params.timeInterval); % For lowess, span needs to be a fraction of total time


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  READ IN  DATA               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[AlignedLFPTrials,LFPSamplingRate,TrialType] = readAndProcessLFPData(Params.datadirectory,Params.commandline{1},Params.trialfile,Params.timeInterval,Params.alphaPlex,Params.electrode1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  COMPUTE THE POWER SPECTRUM  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[power_array]=powerSpectrum(AlignedLFPTrials,LFPSamplingRate,Params.time1,time_step,freq); %Generate Power Spectrum


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
