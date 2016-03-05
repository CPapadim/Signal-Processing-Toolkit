function [ExtractedLFPTrials,LFPTrialTimes,LFPTrialStamps] = extractLFPTrials(Signal,ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,SamplingRate,alpha_plex,commandline)
% EXTRACT LFP TRIALS
%   Split the full LFP Signal into individual trials and select
%   trials whose Trial Stamp matches the Reach Trial Stamps
%
% Function Parameters	
%           Signal (The LFP signal to split)
%			ReachTrialStamps (Reach trial stamps to match)
%			LFPTrialStamps (LFP trial stamps)
%			LFPTrialTimes (Start time of each LFP trial)
%			SamplingRate (Sampling rate of Signal)
%
%
% Output		
%           ExtractedLFPTrials (cell array of trials)
%           ExtractedLFPIndex (Index of extracted LFP trials)
%        
	
	
    % Convert Trial Times to signal sample number
    trialIdx = LFPTrialTimes*SamplingRate; 
    
    % Remove trials that run past the end of the LFP signal
    excessTrials = trialIdx >= length(Signal);
    if any(excessTrials)
        disp(['WARNING: ' num2str(sum(excessTrials)) ' of ' num2str(length(excessTrials)) ' trials ran past the LFP signal. They will be ignored.']);
    end
    trialIdx = trialIdx(~excessTrials);
    LFPTrialTimes = LFPTrialTimes(~excessTrials); 
    LFPTrialStamps = LFPTrialStamps(~excessTrials);

    %For each trial, pull out the part of Signal associated with it
    for i=1:length(trialIdx)
        if i==length(trialIdx)
            LFPTrialArray{i}=Signal(ceil(trialIdx(i)):end);
        else
            LFPTrialArray{i}=Signal(ceil(trialIdx(i)):ceil(trialIdx(i+1)-1));
        end
    end
    
	%Match up reach trials to LFP trials when there are more trials in the LFP files than in the Reach files
	[junk_logicalReturn ordered_matches] = ismember(ReachTrialStamps,LFPTrialStamps);
	ordered_matches(ordered_matches == 0)=[]; %remove no match
	ExtractedLFPTrials=LFPTrialArray(ordered_matches);
    LFPTrialTimes=LFPTrialTimes(ordered_matches);
    LFPTrialStamps=LFPTrialStamps(ordered_matches);

    %If there are duplicate trial stamps due to Reach restarts use trial time differences from trial to trial to do the LFP / Reach matching correctly
	if(alpha_plex==0)
        [LFPTrialStamps,LFPTrialTimes,ExtractedLFPTrials]=remDupTrialStamps(ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,ExtractedLFPTrials,commandline);
								    
	end

end
