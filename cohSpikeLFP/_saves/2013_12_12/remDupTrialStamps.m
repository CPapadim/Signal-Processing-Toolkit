function [LFPTrialStamps,LFPTrialTimes,LFPTrialArray] = remDupTrialStamps(ReachTrialStamps,LFPTrialStamps,LFPTrialTimes,LFPTrialArray,commandline)
% Match Reach and LFP trials correctly when there are duplicate trial stamps

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Reach Trial Times		%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	commandline=char(commandline{1});
	[status, result]=system([commandline(1:strfind(commandline,'-')-1) '-R5 ' commandline(strfind(commandline,'-'):end)]);
	grabdata=textscan(result,'%s %s %s %s %s %s %s %s %s %s %s');

	ReachTrialTimes=str2num(char(grabdata{5}));

	diffRTT=diff(ReachTrialTimes); %Reach Trial Times are in seconds


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% LFP Trial Times		%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	diffLTT=diff(LFPTrialTimes)/1000; %LFPTrialTimes are in milliseconds

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Compare Trial Time Differences (20 Trials or Max Available)	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	compIdx=find(LFPTrialStamps==ReachTrialStamps(1));
	matchfound=0;
	for i = 1:length(compIdx)
		if(length(diffRTT(compIdx(i):end))>20 & length(diffLTT(compIdx(i):end))>20)
			numtocheck=20;
		else
			numtocheck=min([length(diffRTT(compIdx(i):end)) length(diffLTT(compIdx(i):end))]);
		end
		vec2=diffRTT(1:numtocheck);
		vec1=diffLTT(compIdx(i):compIdx(i)+numtocheck-1);
		if(abs(vec1-vec2)<=0.5)
			matchfound=matchfound+1;
			lfpmatchidxStart=compIdx(i);
			if(i==length(compIdx))
				lfpmatchidxEnd=length(LFPTrialStamps);
			else
				lfpmatchidxEnd=compIdx(i+1)-1;
			end
		end
	end
	if(matchfound==0)
		error('LFP-Reach Trial Matching Failed: NO MATCH FOUND');
	elseif(matchfound>1)
		error('LFP-Reach Trial Matching Failed: MULTIPLE POSSIBLE MATCHES FOUND');
	end
	
	LFPTrialArray=LFPTrialArray(lfpmatchidxStart:lfpmatchidxEnd);
	LFPTrialStamps=LFPTrialStamps(lfpmatchidxStart:lfpmatchidxEnd);
	LFPTrialTimes=LFPTrialTimes(lfpmatchidxStart:lfpmatchidxEnd);



end
