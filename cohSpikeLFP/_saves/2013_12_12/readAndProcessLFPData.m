function [AlignedLFPTrials,LFPSamplingRate,ExtractedTrialType,ExtractedTrialStamps,ExtractedReachTrialIndex] = readAndProcessLFPData(datadirectory, commandline, trialfile, time_interval, alpha_plex, electrode)

%
% Function parameters: directory of a data file, the name of a trial
%  file (stamp,time offset in ms,condition type), interval length (ms),
%  time window size (ms), start freq (Hz), end freq (Hz), freq window
%  step (Hz), Electrode LFP Channel
%
%
% Output
%	AlignedLFPTrials - Matrix of Aligned and Truncated LFP Trials
%	LFPSamplingRate - Sampling rate of LFP Signal
%	ExtractedTrialType - Vector of Trial Types for each AlignedLFPTrials
%	ExtractedTrialStamps - Vector of Trial Stamps for each AlignedLFPTrials
%	ExtractedReachTrialIndex - Vector of Reach Trials for which LFPs exist

[ReachTrialStamps, StartTime, TrialType]=loadReachData(trialfile); %Load Reach Data
[LFPTrialStamps,LFPTrialTimes,LFPSignal,LFPSamplingRate]=loadLFPData(electrode,datadirectory, alpha_plex); %Load LFP Data
[FilteredLFPSignal]=filterSignal(LFPSignal,LFPSamplingRate); %Filter LFP Data (Notch, Highpass, Lowpass)

[ExtractedLFPTrials,LFPTrialTimes,LFPTrialStamps] = extractLFPTrials(FilteredLFPSignal,ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,LFPSamplingRate,alpha_plex,commandline); %Extract LFP trials (and corresponding trial indeces) whose trial stamps match reach trial stamps


ExtractedTrialType=TrialType(ismember(ReachTrialStamps,LFPTrialStamps)); %Only keep trial types for the trials we extracted.
ExtractedTrialStamps=ReachTrialStamps(ismember(ReachTrialStamps,LFPTrialStamps)); %Only keep trial stamps for the trials we extracted.
ExtractedStartTime=StartTime(ismember(ReachTrialStamps,LFPTrialStamps)); %Only keep start times for trials we extracted
ExtractedReachTrialIndex=find(ismember(ReachTrialStamps,LFPTrialStamps)); %The index of Reach Trials for which LFPs exist

[AlignedLFPTrials] = alignLFPTrials(ExtractedLFPTrials,ExtractedStartTime,time_interval,LFPSamplingRate); %Align and truncate LFP data to the specified time interval

end
