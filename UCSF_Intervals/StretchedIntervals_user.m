% StretchedIntervals_user - stimulus generation function of experiment 'StretchedIntervals' -
%

function StretchedIntervals_user

global def
global work
global set
global msg

% checkval = 0;
% while checkval < 1
%     ref_note_numbers = floor(rand(1,set.num_notes).*length(set.scale_steps))+1; %%Selects items within scale_steps with replacement 
%     check_doubles = diff(ref_note_numbers);
%     if length(find(check_doubles==0)) < 1       %Makes sure that there are no consecutive repeats.
%         checkval = checkval+1;
%     else checkval = 0;
%     end
% end


stimGenStartTime = tic;

set.lowfreq_base_Hz = work.exppar3;
set.highfreq_base_Hz = set.lowfreq_base_Hz.*2.^(set.nominalIntervalSeparation);

%set.roverangeocts = 0; % For debugging, set rove to zero

set.note_numbers = [0 work.exppar2 0];  % Sets up a pattern of [b n b], where b is the low note and n is the number of semitones for the reference interval.

fixed_notes_factors = 2.^(set.note_numbers./12);   %Steps in terms of semitones above base frequency

%Adaptive factor based on stretch of intervals (10log10(semitones))
%var_notes_factors = fixed_notes_factors.^(10^(work.expvaract./10));   % Stretched (compressed) steps.

%Adaptive factor based on semitone increase/decrease of interval (ST)
var_notes_numbers = [0 work.exppar2+work.expvaract 0];
var_notes_factors = 2.^(var_notes_numbers./12);

lowrove = (rand-0.5)*set.roverangeocts;
highrove = (rand-0.5)*set.roverangeocts;

lowfreqbase = set.lowfreq_base_Hz.*2^lowrove;
highfreqbase = set.highfreq_base_Hz.*2^highrove;

switch work.exppar1
    case 0              %Low tones fixed
        ref_freqs = lowfreqbase.*fixed_notes_factors;
        test_freqs = highfreqbase.*var_notes_factors;        
    case 1              %High tones fixed
        test_freqs = lowfreqbase.*var_notes_factors;
        ref_freqs = highfreqbase.*fixed_notes_factors;
    otherwise
        error('Value must be 0 or 1')
end
set.ref_freqs = ref_freqs(1:2);
set.test_freqs = test_freqs(1:2);
% refOffsets = interp1(log10(set.calFreqs),set.calLevels,log10(ref_freqs))
% testOffsets = interp1(log10(set.calFreqs),set.calLevels,log10(test_freqs))

tref1 = [];
tuser = [];
for i = 1:set.num_notes
    tref1 = [tref1...
        scale(hann(tone(ref_freqs(i),set.tone_dur_ms,0,def.samplerate),set.ramp_dur_ms,def.samplerate),...
            set.level_per_tone+interp1(log10(set.calFreqs),set.calLevels,log10(ref_freqs(i)))),...
        set.silence];
    tuser = [tuser...
        scale(hann(tone(test_freqs(i),set.tone_dur_ms,0,def.samplerate),set.ramp_dur_ms,def.samplerate),...
            set.level_per_tone+interp1(log10(set.calFreqs),set.calLevels,log10(test_freqs(i)))),...
        set.silence];
end


if isfield(def,'exppar5')
    % Set default vocoder parameters
    vocoderCondition = set.vocoderCondition;
    carrierDensity = 1;
    carrierLCO = 50;
    carrierHCO = 15000;
    spread = -12;
    dynamicRange = Inf;
    freqShift = [];  %shift is determined by vocoderCondition. This input is deprecated in spiral_UCSF and is left empty.
    
    tref1 = spiral_UCSF(tref1',vocoderCondition,carrierDensity,carrierLCO,carrierHCO,spread,dynamicRange,freqShift,def.samplerate)';
    tuser = spiral_UCSF(tuser',vocoderCondition,carrierDensity,carrierLCO,carrierHCO,spread,dynamicRange,freqShift,def.samplerate)';
end



if work.expvaract > 0
    msg.correct_msg = '--- CORRECT ---';
    msg.false_msg = '--- WRONG ---';
else
    msg.correct_msg = '--- WRONG ---';
    msg.false_msg = '--- CORRECT ---';
end 


% pre-, post- and pausesignals (all zeros here)

presig = zeros(def.presiglen,2);
postsig = zeros(def.postsiglen,2);
pausesig = zeros(def.pauselen,2);

work.signal = [tuser' tuser' tref1' tref1'];	% left = right (diotic) first two columns holds the test signal (left right)
work.presig = presig;						% must contain the presignal
work.postsig = postsig;					   % must contain the postsignal
work.pausesig = pausesig;				 % must contain the pausesignal


% This should capture most of the stimulus generation time on a per-trial
% basis.
stimGenTime = toc(stimGenStartTime);
work.elapsedTime = work.elapsedTime+stimGenTime;
