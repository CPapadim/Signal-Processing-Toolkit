function [LFPTrialStamps,LFPTrialTimes,LFPSignal,LFPSamplingRate]=loadLFPData(electrode, datadirectory, alpha_plex)
%Loads lfp data and performs some necessary checks and corrections 
%
% NOTE: 	For alpha-omega Harry's encoding (alpha_plex=0) function assumes that directory file listing
%		comes out in order of recording time.  This is will only be the case if the naming convention
%		used by Harry is preserved.  Specifically, when alpha_plex=0 only load files for which filenames
%		are the same date and for which the file number has the same number of total digits (3 in Harry's
%		data). E.g. 13-04-01-001.mat, 13-04-01-002.mat work together.  13-04-01-0003.mat will not work
%		with the -001.mat and -002.mat files, but will work with 13-04-01-0004.mat
%
% Function Parameters:	electrode (channel of electrode), 
% 			datadirectory (directory of the REACH file)
%			alpha_plex (alpha-omega (0) or plexon (1) filetypes?)
%
%
% Output:	LFPTrialStamps (Stamp of each trial) 
%		LFPTrialTimes (Time of each trial)
%		LFPSignal (Raw LFP recordings)
%		LFPSamplingRate (Sampling rate of LFP recordings)
%
%%%%%NOTE:  SPURIOUS BIT and DROPPED PULSES corrections in the Alpha-Omega data assume 12.5KHz sampling rate in the encoding line and clock line%%%%%


warning off all

if(alpha_plex==0)
	lfpdirectory=[datadirectory(1:16) '/LFPs/' datadirectory(18:end) '/'];
elseif(alpha_plex==1)
	% LHS - replaced with next line lfpdirectory=[datadirectory(1:end) '/'];
	slashes=strfind(datadirectory,'/');
	lastslash=slashes(end);
	lfpdirectory=datadirectory(1:lastslash);
	lfpfile=datadirectory(lastslash+1:end);
end
lfpdirlist=dir(lfpdirectory);

LFPSignal=[];

        for ii = 1:size(lfpdirlist,1)
                if (~isempty(regexp(lfpdirlist(ii).name, '\.mat$'))) %Find all the .mat files	
			if(alpha_plex==0)  %Read in Alpha Omega data
                                if(electrode==1) %Load up the data from the correct electrode
                                        S=load([lfpdirectory lfpdirlist(ii).name],'CLFP1','CLFP1_KHz','CDIG1_Up','CDIG2_Up','CDIG2_KHz','CDIG1_Down','CDIG2_Down');
                                        CLFP=S.CLFP1;
                                        CLFP_KHz=S.CLFP1_KHz;
                                elseif(electrode==2)
                                        S=load([lfpdirectory lfpdirlist(ii).name],'CLFP2','CLFP2_KHz','CDIG1_Up','CDIG2_Up','CDIG2_KHz','CDIG1_Down','CDIG2_Down');
                                        CLFP=S.CLFP2;
                                        CLFP_KHz=S.CLFP2_KHz;
                                elseif(electrode==3)
                                        S=load([lfpdirectory lfpdirlist(ii).name],'CLFP3','CLFP3_KHz','CDIG1_Up','CDIG2_Up','CDIG2_KHz','CDIG1_Down','CDIG2_Down');
                                        CLFP=S.CLFP3;
                                        CLFP_KHz=S.CLFP3_KHz;
                                elseif(electrode==4)
                                        S=load([lfpdirectory lfpdirlist(ii).name],'CLFP4','CLFP4_KHz','CDIG1_Up','CDIG2_Up','CDIG2_KHz','CDIG1_Down','CDIG2_Down');
                                        CLFP=S.CLFP4;
                                        CLFP_KHz=S.CLFP4_KHz;
                                end
				
				lfpdirlist(ii).name
				if(~isfield(S,'CDIG1_Up') | ~isfield(S,'CDIG1_Down') | ~isfield(S,'CDIG2_Up') | ~isfield(S,'CDIG2_Down'))
					~isfield(S,'CDIG1_Up')
					~isfield(S,'CDIG1_Down')
					~isfield(S,'CDIG2_Up')
					~isfield(S,'CDIG2_Down')
					warning_msg=['No pulses found in one of the 4 digital variables.  Skipping file ' lfpdirlist(ii).name]
					continue;  % If digital pulses don't exist in the first file, skip the file and move on to the next loop iteration
				end

                                if(isempty(LFPSignal))
                                        LFPSignal=CLFP;
					CDIG1_Up=S.CDIG1_Up;
					CDIG2_Up=S.CDIG2_Up;
					CDIG2_Down=S.CDIG2_Down;
					CDIG1_Down=S.CDIG1_Down;

                                else
                                        LFPSignal=[LFPSignal CLFP];
                                        S.CDIG1_Up=S.CDIG1_Up+double(int32(lfpsize*CDIG2_KHz/LFPSamplingRate));
                                        CDIG1_Up=[CDIG1_Up S.CDIG1_Up];
                                        S.CDIG2_Up=S.CDIG2_Up+double(int32(lfpsize*CDIG2_KHz/LFPSamplingRate));
                                        CDIG2_Up=[CDIG2_Up S.CDIG2_Up];

                                        S.CDIG2_Down=S.CDIG2_Down+double(int32(lfpsize*CDIG2_KHz/LFPSamplingRate));
                                        CDIG2_Down=[CDIG2_Down S.CDIG2_Down];
                                        S.CDIG1_Down=S.CDIG1_Down+double(int32(lfpsize*CDIG2_KHz/LFPSamplingRate));
                                        CDIG1_Down=[CDIG1_Down S.CDIG1_Down];

                                end
                                lfpsize=length(LFPSignal);
                                LFPSamplingRate=CLFP_KHz;
                                CDIG2_KHz=S.CDIG2_KHz;
		
				%TRIAL STAMP BINARY CODE ERROR CHECKING- START
        		
					%CORRECT SPURIOUS BITS - START - NOTE: ASSUMES 12.5KHz sampling rate%
					CDIG1_Down=[CDIG1_Down(diff(CDIG1_Down)~=0) CDIG1_Down(end)];
					CDIG2_Down=[CDIG2_Down(diff(CDIG2_Down)~=0) CDIG2_Down(end)];
					CDIG1_Up=[CDIG1_Up(diff(CDIG1_Up)~=0) CDIG1_Up(end)];
					CDIG2_Up=[CDIG2_Up(diff(CDIG2_Up)~=0) CDIG2_Up(end)];
         				
					if(size(CDIG1_Down,2) > size(CDIG1_Up,2)) %If we start or stop recording during the time-stamp and thus have different size Up and Down vectors, remove the extra pulse.
		                		CDIG1_Down=CDIG1_Down(2:end);
		        		elseif(size(CDIG1_Down,2) < size(CDIG1_Up,2))
               			 		CDIG1_Up=CDIG1_Up(2:end);
        				end
			
		        		removeidx=find((CDIG1_Down-CDIG1_Up)<3); %Find all pulses that lasted for less than X samples.
      			  		CDIG1_Down(removeidx)=[]; %Remove those pulses from CDIG1_Down
        				CDIG1_Up(removeidx)=[]; %Remove those pulses from CDIG1_Up
    			    		%CORRECT SPURIOUS BITS - END%
			
					%----------------------------%

                			%CORRECT DROPPED PULSES - START - NOTE:  ASSUMES 12.5KHz sampling rate%
                			%difference of more than groupDelta indicates a new (pseudo-)group
                			groupDelta = 15;
                			groupJump = [1 diff(CDIG2_Up) > groupDelta];

                			%# number the groups
                			groupNumber = cumsum(groupJump);

                			%# count, for each group, the numbers.
                			groupCounts = hist(groupNumber,1:groupNumber(end));

                			%# if a group contains fewer than 17 entries, throw it out
                			badGroup = find(groupCounts < 17);
                			CDIG2_Up(ismember(groupNumber,badGroup)) = [];
        				%CORRECT DROPPED PULSES - END%

				%TRIAL STAMP BINARY CODE ERROR CHECKING- END


				encoding=CDIG1_Up;
                		clock=CDIG2_Up;

       				rangeclock=[];
        			for i = -2:2 %Define range of clock line samples to check for pulses
                        		rangeclock = [rangeclock; clock+i];
        			end

        		elseif(alpha_plex==1)  %Read in Plexon data
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                %%%%%   NOTE: This chunk of code only reads one (specified by grab) LFP file  %%%%
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				if(lfpdirlist(ii).name==lfpfile)	
					S=load([lfpdirectory lfpfile],'tsevs','allad','adfreq');
                			tsevs=S.tsevs;
                			allad=S.allad;

					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					%%%%  NOTE:  ERIC'S MAPPING   %%%%%%%
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

					channel=[];
					for i = 1:16
						if(length(allad{i})>1)
							channel=[channel i];
						end
					end
					electrode=channel(electrode);
					
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					%%%%  NOTE:  ERIC'S MAPPING - END  %%%%%%%
					%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
					LFPSamplingRate=S.adfreq/1000;
					LFPSignal=allad{electrode}';
					
					PLEXDIG_Up=[];  %Create a simulated clock line for the plexon
					i=1;
					while i <= size(tsevs{2},1)
						PLEXDIG_Up=[PLEXDIG_Up tsevs{2}(i)+(0:16)*0.01]; %17 pulses 0.01 seconds appart
						i=find(tsevs{2} > tsevs{2}(i)+16*0.01,1); %find the next trial
					end

					encoding=int32(10000*tsevs{2}');
					clock=int32(10000*PLEXDIG_Up);
			
					rangeclock=[];
					for i = -2:2
						rangeclock = [rangeclock; clock+i];
					end
				end
        		end

                end
        end
        
	
	%Decode LFP Trial Stamps
	Match = sum(ismember(rangeclock, encoding),1) > 0; %Check for encoding-line pulses at each clock-line pulse, including the pulse range
        %  If any of the values in 'clock' matches the values in data, a '1' (true) is registered into 'M'
        N=reshape(Match,17,(size(Match,2)/17))'; %reshape vector Match into an M x 17 matrix: Each row is the binary code for a trial
        LFPTrialStamps=bin2dec(num2str(N(:,2:end)));  %convert trial numbers from binary to base 10
	
	%Calculate LFP Trial Times
	if(alpha_plex==0)
                O=reshape(clock,17,(size(clock,2)/17))'; %Use the clock to generate trial times
                LFPTrialTimes=O(:,1)/CDIG2_KHz; %Trial times in milliseconds
        elseif(alpha_plex==1)
                O=reshape(PLEXDIG_Up,17,(size(PLEXDIG_Up,2)/17))'; %Use the simulated clock-line to generate trial times
                LFPTrialTimes=O(:,1)*1000; %Trial Times in milliseconds.
		LFPTrialTimes=LFPTrialTimes(LFPTrialStamps>0); %Removes Trial Times when Time stamp is 0 in plexon stray pulses
        end
	
	LFPTrialStamps=LFPTrialStamps(LFPTrialStamps>0); %Removes Trial Stamps of 0 created by random stray pulses within a trial when using the plexon.  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%READ IN LFP DATA END%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


