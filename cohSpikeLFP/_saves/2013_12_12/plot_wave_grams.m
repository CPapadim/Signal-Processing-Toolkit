function [h1] = plot_wave_grams(image,center_freq,align,Fs,varargin)


% used for plotting output from wave_grams
%  INPUT:
%           image = one of the outputs from wave_gram, 2-d matrix, trialsXtime
%           center_freq = center frequencies of wavelets used in cwt
%           align = the alignement time, or time zero in the plot
%           Fs = sampling frequency
%           Varargin:
%           type = type of image being plotted
%           idx = trial type selected
% OUTPUT:
%           h1 = handle to the figure

l = size(image,2);
t = (0:l)/Fs - align;
if length(varargin)>0
    type = char(varargin{1});
    
    %%% this was used to preset ranges, but for now, I want to let matlab
    %%% set range,  cc commented out below
    if strcmp(type,'mag')
        cc = [-15 15];
    elseif strcmp(type,'phase')
        cc = [0 2*pi];
    elseif strcmp(type,'cohere')
        cc = [0 1];
    else
        cc = [min(image) max(image)]
    end
else
    cc = [min(min(image)) max(max(image))];
    type = 'type not specified';
end
if length(varargin)>1
    type = strcat(type,'--class = ',num2str((varargin{2})));
end
    %PLotting commands
    h1 = figure;
    imagesc(t,center_freq,image);
    set(gca,'YDir','normal');colormap('bone');%caxis(cc); % frequency axis from low to high bottom to top, black and white, and compressing percent scale
    xlabel('Time(s)');ylabel('Center-Frequency');title(type);
    colorbar
    
    
