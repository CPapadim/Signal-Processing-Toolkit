function [Spikes] = loadSpikes(spikefile)
% Load and Align trial by trial spikes
%
% Parameters
%		spikefile - File of trial by trial spike times
%
% Output
%		Spikes - Trial x Time

	%importdata('SpikeData.temp',1);
	
%%%ALPHA OMEGA
	Spikes=cell(1); %Create Cell array
	fid=fopen(char(spikefile));
	i=0;
	while ~feof(fid)
		i=i+1;
		readline=sscanf(fgetl(fid), '%f');
		if(i > 1) %ignore header line
			Spikes{i-1} = readline;
		end
	end
	fclose(fid);


%%%%%PLEXON - NEED TO WRITE OWN loadSpikesPlexon function since loading from plexon needs a totally different set of parameters than loading from reach files


end
