function [ReachTrialStamps, StartTime, TrialType] = loadReachData(filename);
%Load Data from grab-generated file filename
%
% Function Parameters	filename (Name of file to load)
%
%
% Output	ReachTrialStamps (Trial stamp for each trial)
%		StartTime (Start time for each trial)
%		TrialType (Trial type for each trial, e.g. class/stack)
%
fid=fopen(char(filename));
TrialData=textscan(fid,'%f %f %f','headerlines',1);
fclose(fid);

ReachTrialStamps=TrialData{1};
StartTime=TrialData{2};
TrialType=TrialData{3};


end
