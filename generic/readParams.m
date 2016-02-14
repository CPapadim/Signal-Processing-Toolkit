function [Params] = readParams(paramfile);

% Reads parameters passed by grab
% 
% Function parameters: 
%			paramfile - file containing the parameters
%
%
% Output:
%	commandline - the command line entered
%	datadirectory - directory containing the data
%	trialfile - file containing trial data
%	spikefile - file containing spike times
%	timeInterval - the time interval over which to do analysis
%	time1 - ot parameter
%	time2 - ot parameter
%	filter - filter / smoothing amount
%	electrode1 - channel number of first electrode containing data
%	electtrode2 - channel number of second electrode containing data
%	freqStart1 - start of requency range to analyze
%	freqEnd1 - end of frequency range to analyze
%	freqStep1 - step size of frequencies between start and end
%	alpha_plex - identifies the Reach Setup used to collect the data
%	hemisphere - which side?  Not used by the matlab code, just passed on
%   freqStart2
%   freqEnd2
%   freqStep2


	fid                = fopen(paramfile);
	Params.commandline = textscan(fid,'%s',1,'delimiter','\n');

    paramsline       = textscan(fid,'%s',1,'delimiter','\n');
    Params.paramsstr = paramsline{1}{1};
	params           = textscan(Params.paramsstr,'%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f');
	fclose(fid);

	Params.datadirectory   = char(params{1});
	Params.trialfile       = params{2};
	Params.spikefile       = params{3};
	Params.timeInterval    = params{4};
	Params.time1           = params{5};
	Params.time2           = params{6};
	Params.filter          = params{7};
	Params.electrode1      = params{8};
	Params.electrode2      = params{9};
	Params.freqStart1      = params{10};
	Params.freqEnd1        = params{11};
	Params.freqStep1       = params{12};
	Params.alphaPlex       = params{13};
	Params.hemisphere      = params{14};	% not used here (but written into output file)
    Params.freqStart2      = params{15};
    Params.freqEnd2        = params{16};
    Params.freqStep2       = params{17};
end

