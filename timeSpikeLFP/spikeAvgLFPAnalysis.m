function [SpikeAvgdLFP]=spikeAvgLFPAnalysis(LFPTrials,LFPSamplingRate,TrialSpikes,time_start,time_end);

% Calculate Spike Averaged LFP
%
% 	Parameters:
%			LFPTrials - Array of Aligned LFP trials
%			LFPSamplingRate - Sampling Rate of LFP Trials
%			TrialSpikes - Array of Spikes (0 = No Spike, 1 = Spike) for each
%				      sample of each LFP trial (same size as LFPTrials)
%			time_start, time_end - Defines the time borders around the spike
%					       for which to average LFPs
%
%	Output:
%			SpikeAvgdLFP - Trial x Time (time window length) array of
%				       Spike Averaged LFP of each trial.
%				       When a trial has no qualifying spikes, NaNs are
%				       returned for that trial

	time_start_samples=floor(time_start*LFPSamplingRate)+1;
	time_end_samples=floor(time_end*LFPSamplingRate)+1;

	for i=1:size(TrialSpikes,1)
		border1=find(TrialSpikes(i,:)==1)+time_start_samples;
		border2=find(TrialSpikes(i,:)==1)+time_end_samples;
		TrialSpikeTriggeredLFP=[];
		usedSpikeCount=0;
		for j=1:length(border1)
			if(border1(j)>0 & border2(j) <= size(LFPTrials,2))
				usedSpikeCount=usedSpikeCount+1;
				TrialSpikeTriggeredLFP(usedSpikeCount,:)=LFPTrials(i,border1(j):border2(j));
			end
		end

		%Set trials that don't have spikes (that qualify) to NaN to preserve trial numbers without affecting data
		if(~isempty(TrialSpikeTriggeredLFP))
			SpikeAvgdLFP(i,1:length(time_start_samples:time_end_samples))=mean(TrialSpikeTriggeredLFP,1);
		else
			SpikeAvgdLFP(i,1:length(time_start_samples:time_end_samples))=NaN;
		end
	end


end
