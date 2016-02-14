function [FilteredSignal] = filterSignal(Signal,SamplingRate)
%Filteres the input signal with a variety of filters
%
% Function Parameters	Signal (The signal to be filtered)
%			SamplingRate (The sampling rate of the signal)
%
%
% Output		FilteredSignal (The filtered signal)
%

	warning off all
        %FILTERS---All values are in Hz%
        %HIGHPASS%
        Fs=SamplingRate*1000;
        Fstop=5; %Stopband Frequency
        Fpass=8; %Passband Frequency
        Astop=80; %Stopband Attenuation(dB)
        Apass=0.1; %Passband Ripple (dB)
        match='stopband'; %Band to match exactly

        h=fdesign.highpass(Fstop, Fpass, Astop, Apass, Fs);
        Hd=design(h, 'butter', 'MatchExactly', match);


        %LOWPASS%
        Fs=SamplingRate*1000;
        Fstop=150; %Stopband Frequency
        Fpass=148; %Passband Frequency
        Astop=80; %Stopband Attenuation(dB)
        Apass=0.1; %Passband Ripple (dB)
        match='stopband'; %Band to match exactly

        h2=fdesign.lowpass(Fpass, Fstop, Apass, Astop, Fs);
        Hd2=design(h2, 'cheby2', 'MatchExactly', match);


  	%NOTCH FILTER FOR 60Hz%
        NotchFreq=60;
        wo = NotchFreq/(SamplingRate*1000/2);
        bw = wo;
        [notch_b,notch_a] = iirnotch(wo,bw);

	
	%APPLY FILTERS
     	%Signal=filtfilt(notch_b,notch_a,Signal); %Apply Notch
        %Signal=filtfilt(Hd2.sosMatrix,Hd2.ScaleValues,Signal); %Lowpass
        %Signal=filtfilt(Hd.sosMatrix,Hd.ScaleValues,Signal); %Highpass

	FilteredSignal=Signal;

end

