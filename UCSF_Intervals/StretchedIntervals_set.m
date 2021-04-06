% StretchedIntervals_set - setup function of experiment 'StretchedIntervals'

function StretchedIntervals_set

global def
global work
global set

set.max_level = findmaxlevel(work.userpar1,work.userpar2);
set.tone_dur_ms = 300;
set.silence_dur_ms = 200;
set.ramp_dur_ms = 10;
set.num_notes = 3;
set.vocoderCondition = work.int_exppar5{1};



switch work.int_exppar3{1} 
    case 2180% apply a smaller max interval size limit for the mid/high frequencies.
%         def.maxvar = 6;
%         set.roverangeocts = 1/2;
%         set.nominalIntervalSeparation = -2*work.exppar4;
    case 572
        def.maxvar = 11;
        set.roverangeocts = 1/2;
        set.nominalIntervalSeparation = work.int_exppar4{1};
    case 150
        def.maxvar = 11;
        set.roverangeocts = 1/2;
        set.nominalIntervalSeparation = work.int_exppar4{1};
    otherwise
        error(['Base Frequency: ' num2str(work.exppar3) ' unexpected. Expected frequencies [150 572 2180]. Check cfg file or define a new case in StretchedIntervals_set.m'])
end

def.minvar=-work.int_exppar2{1}; %Make sure that the interval direction can't be reversed (ie minimum interval size is 0 ST)

def.intervallen = round(set.num_notes .* (set.tone_dur_ms+set.silence_dur_ms).*def.samplerate./1000);	% length of each signal-presentation interval in samples (might be overloaded in 'expname_set')
set.level_per_tone = 60-set.max_level;
set.silence = tone(1000,set.silence_dur_ms,0,def.samplerate).*0;

% calFileLoc = '/labs/oxenhamlab/ToneCalibration/';
% calFileLoc = 'C:\Users\Jbeim\OneDrive\Documents\MATLAB\local scripts\Online Experiments\UCSF_Intervals\';
exp = def.expname;
id = work.vpname;
% calFile = [calFileLoc id '_' exp '.mat'];

set.calFreqs = [125 250 500 2000 7352];
set.calLevels = zeros(size(set.calFreqs));

% if def.modelEnable == 1
%     set.calFreqs = [125 250 500 2000 7352];
%     set.calLevels = zeros(size(set.calFreqs));
% else
%     if exist(calFile,'File')
%         caldata = load(calFile);
%         set.calFreqs = caldata.allFreqs;
%         set.calLevels = caldata.levels;
%     else 
%         if isfield(def,'afc_message')
%             % this works on web only
%             def.afc_message.Value = 'No calibration data found. Please contact the researcher.';
%         else
%             error('No calibration data found. Please contact the researcher');
%         end    
%     end
% end
% eof