function [AlignedLFPTrials] = alignLFPTrials(LFPTrials,startTime,timeInterval,LFPSamplingRate);
% Align and truncate LFP trials so that they start at
% their respective startTime and end at startTime + timeInterval
%
% Function Parameters	LFPTrials (Cell array of LFP Trials to align)
%			startTime (Array of start times, one for each trial)
%			timeInterval (duration of trials, same for all trials)
%			LFPSamplingRate (LFP sampling rate)
%
%
% Output		AlignedLFPTrials (LFP trial array truncated and aligned)
%
        timeInterval_samples=round(timeInterval*LFPSamplingRate);
        startTime_Samples=round(startTime.*LFPSamplingRate);
	for i=1:size(LFPTrials,2)
                AlignedLFPTrials(i,:)=LFPTrials{i}(startTime_Samples(i):startTime_Samples(i)+timeInterval_samples-1);

        end
end
