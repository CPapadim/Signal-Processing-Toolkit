function [ExtractedLFPTrials,LFPTrialTimes,LFPTrialStamps] = extractLFPTrials(Signal,ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,SamplingRate,alpha_plex,commandline)
% Split the full LFP Signal into individual trials and select
% trials whose Trial Stamp matches the Reach Trial Stamps
%
% Function Parameters	Signal (The LFP signal to split)
%			ReachTrialStamps (Reach trial stamps to match)
%			LFPTrialStamps (LFP trial stamps)
%			LFPTrialTimes (Start time of each LFP trial)
%			SamplingRate (Sampling rate of Signal)
%
%
% Output		ExtractedLFPTrials (cell array of trials)
%			ExtractedLFPIndex (Index of extracted LFP trials)
%        
	

	trialIdx = LFPTrialTimes*SamplingRate; %Convert Trial Times to signal sample number
        %For each trial, pull out the part of Signal associated with it
        for i=1:length(trialIdx)
            if i==length(trialIdx)
                LFPTrialArray{i}=Signal(ceil(trialIdx(i)):end);
            else
                LFPTrialArray{i}=Signal(ceil(trialIdx(i)):ceil(trialIdx(i+1)-1));
            end
        end
      	
	%Match up reach trials to LFP trials when there are more trials in the LFP files than in the Reach files
	ExtractedLFPTrials=LFPTrialArray(ismember(LFPTrialStamps,ReachTrialStamps));
        LFPTrialTimes=LFPTrialTimes(ismember(LFPTrialStamps,ReachTrialStamps));
        LFPTrialStamps=LFPTrialStamps(ismember(LFPTrialStamps,ReachTrialStamps));

        %If there are duplicate trial stamps due to Reach restarts use trial time differences from trial to trial to do the LFP / Reach matching correctly
	if(alpha_plex==0)
		[LFPTrialStamps,LFPTrialTimes,ExtractedLFPTrials]=remDupTrialStamps(ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,ExtractedLFPTrials,commandline);
								    
	end
	
	% Pick out the LFP Trials that match the reach trials returned by grab
	% REPLACED with other code - Remove if everything is working fine
        %
	%ExtractedLFPTrials={};
	%ExtractedLFPIndex=[];
        %for i=1:size(LFPTrialArray,2)
        %        if(ismember(LFPTrialStamps(i),ReachTrialStamps))
        %                ExtractedLFPTrials{end+1}=LFPTrialArray{i};
	%		ExtractedLFPIndex=[ExtractedLFPIndex i];
        %        end
        %end

end
