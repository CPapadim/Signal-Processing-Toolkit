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


	%%% Loop through all LFP files again
%        	data = load(spikefile,'tscounts','allts'); %Need spike times if plexon
%        	dataChannels = find(data.tscounts(2,:)>1)-1;
%        	spikeTimes = []; %spike times
%
%        	spikeTimes= data.allts{2,dataChannels(electrode)}; %In seconds
		%%% Add (lfpsize/LFPSamplingRate)    to spikeTimes for every file
	%%% LFP FILE LOOP END
        
%	spike_vect = zeros((max(TrialTimes)+time_window)*Fs,1);
%        spike_vect(round(spikeTimes*SamplingRate)) = 1;
%
%        for i = 1:length(TrialTimes)
%                AlignedSpikeTrials(i,:) = spike_vect((TrialTimes(i)+((starttimes(i):starttimes(i)+window)))*Fs)
%        end

end
