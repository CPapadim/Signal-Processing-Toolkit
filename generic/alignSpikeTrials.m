function [AlignedSpikeTrials] = alignSpikeTrials(Spikes,StartTime,time_interval)

% Inputs:
%        Unit: unit number 1 or 2
%        trialtimes = times for each trial
%        starttimes: start times for each trial. same as used to align LFP        
%        Window: Time window of interest, same as LFP interval
%        Fs = sampling rate
%        file = plexon file

% Output:
%        aligned_trial_spikes = matrix of spikes truncated to match
%        window(like LFP)


%IF ALPHA-OMEGA
if(alpha_plex==0)

	%NEEDS MATRIX OF SPIKES (In binary)
	
	timeInterval_samples=floor(timeInterval*LFPSamplingRate);
        startTime_Samples=ceil(startTime.*LFPSamplingRate);
        for i=1:size(LFPTrials,2)
                AlignedLFPTrials(i,:)=LFPTrials{i}(startTime_Samples(i):startTime_Samples(i)+timeInterval_samples);

        end

%IF PLEXON
elseif(alpha_plex==1)
	data = load(file,'tscounts','allts'); %Need spike times if plexon
	dataChannels = find(data.tscounts(2,:)>1)-1;
	spikeTimes = []; %spike times
    
	spikeTimes= data.allts{2,dataChannels(electrode)}; %In seconds


	spike_vect = zeros((max(TrialTimes)+time_window)*Fs,1);
	spike_vect(round(spikeTimes*SamplingRate)) = 1;
	
	for i = 1:length(TrialTimes)
    		AlignedSpikeTrials(i,:) = spike_vect((TrialTimes(i)+((starttimes(i):starttimes(i)+window)))*Fs)
	end
end

%%% Return AlignedSpikeTrials
