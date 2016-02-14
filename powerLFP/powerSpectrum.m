function [power_array]=powerSpectrum(SignalArray,SamplingRate,timeWindow,timeStep,freq)
% Generate power spectrum as a function of time and frequency
%
% Function Parameters 	SignalArray (Array of signals in time to analyze)
%			SamplingRate (Sampling rate of signals)
%			timeWindow (time window size for FFT / PMTM)
%			timeStep (time step for FFT / PMTM)
%			freq (vector of frequencies to analyze)
%
%
% Output		power_array (SignalArray(i) x frequency x time)
%
	fs=SamplingRate*1000;
	trial_duration=size(SignalArray,2)/fs; %how long a single trial lasts
	t=0:(1/fs):trial_duration; %time vector in seconds, one sample's worth of seconds
	t0 = 0:(timeStep)/1000:trial_duration-(timeWindow/1000); %t0 and t1 are borders of the time window
	t1 = t0 + (timeWindow/1000);

	for i=1:size(SignalArray,1) %looping through every trial
       		signal=SignalArray(i,:);
        	P =[];
        	for iter = 1:length(t0)
                	index = t>=t0(iter) & t < t1(iter); %all data in 'signal' inside time window
                	%[P(:,iter),freq]=pmtm(signal(index),[],5000,fs);
                	[P(:,iter),w]=pmtm(signal(index),2.5,freq,fs);
        	end
        	power_array(i,:,:)=P;
	end

end

