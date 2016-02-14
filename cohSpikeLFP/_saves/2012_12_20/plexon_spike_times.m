%%% old, Harry and I changed and added to preprocess module 

function [aligned_trial_spike] = plexon_spike_times(unit,trialtimes,starttimes,window,Fs,file)

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

data = load(file);
chans = find(data.tscounts(2,:)>1)-1;
units = [];
cnt = 1;
for x = chans;
    units{cnt} = data.allts{2,x};
    cnt = cnt +1;
end

spikes = units{unit};

spike_vect = zeros((max(trialtimes)+window)*Fs,1);
spike_vect(round(spikes*Fs)) = 1;

for i = 1:length(trialtimes)
    aligned_trial_spike{i} = spike_vect((trialtimes(i)+((starttimes(i):starttimes(i)+window)))*Fs)
end


