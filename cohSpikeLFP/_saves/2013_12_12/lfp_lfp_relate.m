function [xspec xcohere] = lfp_lfp_relate(lfp_wave_L,lfp_wave_R)

%Inputs:
%       lfp_wave_L and lfp_wave_R = the complex wavelet transform of two
%       lfp signals
%Outputs:  
%        xspec = the wavelet cross spectra of the two signals
%         xcohere = the wavelet cross coherence spectra   


%   This script generates the wavelet cross spectrum and coherence,  since
%   we are using a complex wavelet (cmor)  these are complex,  they can be
%   handed to wave_grams and spike_average_wave just like the individual
%   complex wavelet transforms.  Temporal smoothing may need to be added.
xspec = conj(lfp_wave_L).*lfp_wave_R;
xcohere = xspec./(sqrt(abs(lfp_wave_L).^2).*sqrt(abs(lfp_wave_R).^2));
