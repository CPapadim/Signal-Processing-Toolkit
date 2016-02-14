function [FilteredSignal] = filterLfp(Signal,SamplingRate,FpassH,FstopH,FpassL,FstopL)
%Filteres the input signal with a variety of filters
%
% Function Parameters	
%           Signal (The signal to be filtered)
%			SamplingRate (The sampling rate of the signal)
%		    FpassH (The highpass cuttoff frequency)
%           FstopH (The highpass stopband frequency)
%           FpassL (The lowpass cutoff frequency)
%           FstopL (The lowpass stopband frequency)
%
%
% Output		FilteredSignal (The filtered signal)
%

warning off all

% Signal 
SamplingRate = SamplingRate*1000;
buffer       = floor(size(Signal,2))-10;
lfp_buffer   = [Signal flipud(Signal(:,1:buffer)) Signal flipud(Signal(:,end-buffer:end)) Signal];


%%%%%%%%%%%%%%%%%%%%%%%
% STOP BAND FILTERING %
%%%%%%%%%%%%%%%%%%%%%%%

% Filter parameters
Fpass1 = 56;            % First Passband Frequency
Fstop1 = 57;            % First Stopband Frequency
Fstop2 = 62;            % Second Stopband Frequency
Fpass2 = 63;            % Second Passband Frequency
Apass1 = 0.1;           % First Passband Ripple (dB)
Apass2 = 0.1;           % Second Passband Ripple (dB)
Astop  = 80;            % Stopband Attenuation (dB)
match  = 'stopband';    % Band to match exactly

% Construct an FDESIGN object and call its CHEBY2 method.
h1  = fdesign.bandstop(Fpass1, Fstop1, Fstop2, Fpass2, Apass1, Astop,Apass2, SamplingRate);
Hdbs = design(h1, 'cheby2', 'MatchExactly', match);

% Filter signal
FilteredSignal = filtfilt(Hdbs.SOSMatrix,Hdbs.ScaleValues,lfp_buffer');


%%%%%%%%%%%%%
% BAND PASS %
%%%%%%%%%%%%%

% Only band pass filter is high and low cutoff frequencies were passed.
if (nargin > 2)
    
    % Filter parameters - Low pass
    Fpass = FpassL;         % Passband Frequency
    Fstop = FstopL;         % Stopband Frequency
    Apass = 0.1;            % Passband Ripple (dB)
    Astop = 80;             % Stopband Attenuation (dB)
    match = 'stopband';     % Band to match exactly

    % Construct an FDESIGN object and call its CHEBY2 method.
    h2 = fdesign.lowpass(Fpass, Fstop, Apass, Astop, SamplingRate);
    Hdlp = design(h2, 'cheby2', 'MatchExactly', match);
    
    % Filter signal
    FilteredSignal = filtfilt(Hdlp.SOSMatrix,Hdlp.ScaleValues,FilteredSignal);


    % Filter parameters - High pass
    Fstop = FstopH;         % Stopband Frequency
    Fpass = FpassH;         % Passband Frequency
    Apass = 0.1;            % Passband Ripple (dB)
    Astop = 80;             % Stopband Attenuation (dB)
    match = 'stopband';     % Band to match exactly

    % Construct an FDESIGN object and call its CHEBY2 method.
    h3  = fdesign.highpass(Fstop, Fpass, Astop, Apass, SamplingRate);
    Hdhp = design(h3, 'cheby2', 'MatchExactly', match);
    
    % Filter signal
    FilteredSignal = filtfilt(Hdhp.SOSMatrix,Hdhp.ScaleValues,FilteredSignal);
end

% Final output signal 
FilteredSignal = FilteredSignal(size(Signal,2)+buffer+1:end-size(Signal,2)-buffer-1,:)';
