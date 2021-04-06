% StretchedIntervals_cfg - measurement configuration file -
% randomize;
rng('default')
rng('shuffle')

def.expname = 'StretchedIntervals';
% general measurement procedure
def.measurementProcedure = 'transformedUpDown';	% measurement procedure
def.intervalnum = 2;				% number of intervals
def.rule = [1 2;2 1;1 2;2 1];				% [up down]-rule: [1 2] = 1-up 2-down
def.varstep = [4 2];				% [starting stepsize ... minimum stepsize] of the tracking variable
def.steprule = -1;				% stepsize is changed after each upper (-1) or lower (1) reversal
def.reversalnum = 2;				% number of reversals in measurement phase
def.repeatnum = 5;				% number of repetitions of the experiment
def.ranpos = 0;						% interval which contains the test signal: 1 = first interval ..., 0 = random interval

% experimental variable (result of procedure yields dependent variable)
def.startvar = [3 -3 3 -3]';				% starting value of the tracking variable
def.expvarunit = 'ST';                      % unit of the tracking variable
def.expvardescription = 'Interval change';	% description of the tracking variable

% limits for experimental variable
def.minvar = -10;				% minimum value of the tracking variable (!!Changed in set file!!)
def.maxvar = 11;                % maximum value of the tracking variable
def.terminate = 1;				% terminate execution on min/maxvar hit: 0 = warning, 1 = terminate
def.endstop = 3;				% Allows x nominal levels higher/lower than the limits before terminating (if def.terminate = 1) 

% experimental parameter (independent variable)
def.exppar1 = [0 0 1 1]';	% vector containing experimental parameters for which the exp is performed
def.exppar1unit = 'LoHiFix';                        % unit of experimental parameter
def.exppar1description = 'Low(0) High(1) fixed';  % description of the experimental parameter

def.exppar2 = [7];  % [4 7]
def.exppar2unit = 'ST';
def.exppar2description = 'Reference interval size';


def.exppar3 = [572]; %originally [150 572]
def.exppar3unit = 'Hz';
def.exppar3description = 'Nominal lowest frequency';


def.exppar4 = [1.93]; %For debugging, set to zero. previously [2]
def.exppar4unit = 'Oct';
def.exppar4description = 'Nominal difference between low and high intervals';

def.exppar5 = [1 2 4]; % which vocoder map to use [1] default medel, [2] CT-warped, [4] CT-exact
def.exppar5unit = 'NA';
def.exppar5description = 'Vocoder map';

% interface, feedback and messages 
def.mouse = 1;					% enables mouse/touch screen control (1), or disables (0) 
def.markinterval = 1;				% toggles visual interval marking on (1), off(0)
def.feedback = 0;				% visual feedback after response: 0 = no feedback, 1 = correct/false/measurement phase
def.messages = 'autoSelect';			% message configuration file, if 'autoSelect' AFC automatically selects depending on expname and language setting, fallback is 'default'. If 'default' or any arbitrary string, the respectively named _msg file is used.
def.language = 'EN';				% EN = english, DE = german, FR = french, DA = danish

% save paths and save function
def.result_path = '/Results/';				% where to save results
def.control_path = '/Control';				% where to save control files
def.savefcn = 'default';			% function which writes results to disk

% samplerate and sound output
def.samplerate = 44100;				% sampling rate in Hz
def.intervallen = 22050*3;			% length of each signal-presentation interval in samples (might be overloaded in 'expname_set')
def.pauselen = 22050;				% length of pauses between signal-presentation intervals in samples (might be overloaded in 'expname_set')
def.presiglen = 100;				% length of signal leading the first presentation interval in samples (might be overloaded in 'expname_set')
def.postsiglen = 100;				% length of signal following the last presentation interval in samples (might be overloaded in 'expname_set')
def.bits = 16;					% output bit depth: 8 or 16 see def.externSoundCommand for 32 bits

% interleaved measurement
def.interleaved = 1;				% toggles block interleaving on (1), off (0)
def.interleavenum = 4; 			% number of interleaved runs

% The experiment uses multiple exppars (exppar1 ... exppar3).
% def.parrand has 4 elements for 4 exppars.
def.parrand = [1 1 1 1 1];     % toggles random presentation of the elements in "exppar" on (1), off(0)


%% Webapp required parameters are set here
% % def.afcwin = 'afc_win_forWebapp';
% 
% webDataRoot = [filesep 'labs' filesep 'oxenhamlab' filesep]; % primary directory for storing results
% def.control_path = [webDataRoot def.expname filesep 'Control' filesep]; % control file location
% def.result_path = [webDataRoot def.expname filesep 'Output' filesep];   % output file location
% 
% def.webAudioPath = [filesep 'web' filesep 'catss' filesep 'Audio' filesep]; % location where webAudioPlayer.html and temporary audio files will be stored
% 
% def.trialResponseIntervalTime = 1; % how many seconds should count as the response interval. Experiment does not currently track response time.
% def.externSoundCommand = 'webAudio'; % override standard AFC audio using webAudioPlayer.html.
% def.htmlDebug = 0;
% def.debug = 0; % if debug is not set to 0 afc will produce warnings/errors due to nonstandard parameters stored in the def structure.

%eof