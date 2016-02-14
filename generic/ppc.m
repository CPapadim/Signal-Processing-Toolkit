function [ppcVal] = ppc(phaseArray, trialArray)
% PAIR-WISE PHASE CONSISTENCY
%   Compute the phase consistency of an array of angles.
%   See Vinck et al., 2012.
%

% AUTHOR: Charles D Holmes
% EMAIL:  chuck@eye-hand
%

%%%%%%%%%%%%%
% PROCEDURE %
%%%%%%%%%%%%%

uniqueTrials = unique(trialArray);
dof          = length(uniqueTrials);

S  = zeros(size(phaseArray,1),1);
SS = zeros(size(phaseArray,1),1);
for iTrial = 1:length(uniqueTrials)
    trial       = uniqueTrials(iTrial);
    spikeIdx    = trialArray == trial;
    trialPhases = phaseArray(:,spikeIdx); 

    meanVector = mean(exp(1i*trialPhases),2);
    S          = S + meanVector;
    SS         = SS + meanVector.*conj(meanVector);
end

ppcVal = (S.*conj(S) - SS)/(dof*(dof-1));
