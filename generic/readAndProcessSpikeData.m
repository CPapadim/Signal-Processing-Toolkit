function [TrialSpikes] = readAndProcessSpikeData(trialfile, spikefile, time_interval, SamplingRate, alpha_plex, ReachTrialIndex)

% Reads a spike file and creates a spike vector for each trial where each value is a 0 (no spike)
% or 1 (spike), and vector indices represent LFP sample numbers
% Function parameters: 	trialfile - file of Trial Data
%			spikefile - file of Spike Data
%			time_interval - time interval of trial to take
%			alpha_plex - alpha omega or plexon?  Will eventually be removed when
%				     reading spikes is done the same in both plexon and alpha omega
%			ReachTrialIndex - Index of Reach Trials that have LFPs recorded
%					  Some trials in your reach file may not have
%					  corresponding LFPs.
%					  Argument is optional (needs to stay as last argument)
%					  If all Reach trials have LFPs or if this function is
%					  being used in analyses not involving LFPs, ommit argument
%
%
% Output
%	AlignedLFPTrials - Matrix of Aligned and Truncated LFP Trials
%	LFPSamplingRate - Sampling rate of LFP Signal
%	ExtractedTrialType - Vector of Trial Types for each AlignedLFPTrials
%	ExtractedTrialStamps - Vector of Trial Stamps for each AlignedLFPTrials


	[ReachTrialStamps, StartTime, TrialType]=loadReachData(trialfile); %Load Reach Data
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%  Remove Reach trials without LFP data  %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if(exist('ReachTrialIndex')==0) %If there is no ReachTrialIndex specified, use all trials
		ReachTrialIndex=length(ReachTrialStamps);
	end
	
	ReachTrialStamps=ReachTrialStamps(ReachTrialIndex);
	StartTime=StartTime(ReachTrialIndex);
	TrialType=TrialType(ReachTrialIndex);
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%  Load Spike Times                      %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	[TrialSpikeTimesR]=loadSpikes(spikefile); %Cell array of spike times, each cell is a trial
	for r=1:length(ReachTrialIndex)
		TrialSpikeTimes{r}=TrialSpikeTimesR{ReachTrialIndex(r)}; %Keep only trials with LFP data
	end
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%  Convert Spike Times to Spikes         %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%  Convert spike times to array of 0s (no spike) and 1s (spike) for each LFP Sample  %%%
	time_samples=round(time_interval*SamplingRate);
	TrialSpikes=zeros(length(TrialSpikeTimes),time_samples);
	for i = 1:length(TrialSpikeTimes)
		spikeIndex=round(TrialSpikeTimes{i}.*SamplingRate)+1;
		spikeIndex(spikeIndex > time_samples)=[]; % Remove spikes falling out of bounds
		TrialSpikes(i,spikeIndex)=1;
	end
	

end
