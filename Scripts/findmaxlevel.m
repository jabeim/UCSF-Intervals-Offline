
%findmaxlevel('booth','PA4 attenuation',['headphones'])
%Calculates maximum output level, based on the booth ('n640', 'n640_1', 'ci1' or 'booth7'),
%headphone type (HD580 or ER2).
%All arguments must be given as strings, i.e. in single quotes
%The maxlevel is the level in dB SPL, produced by a full-scale-deflection
%sinusoid (peak amplitude of 1 in Matlab)
%Modified AJO 6/29/09. Added Crown amp option
%Modified AJO 2/14/12. Added HD650 headphones
%Modified AJO 8/19/13. Made HD650 default.
% 3/15/16. AJO. Added EAR3A headphones under N640. ~2 dB higher than HD650s
%1/23/17. AJO. Changed ci2 to booth7 to reflect move to N625.

function maxlevel = findmaxlevel(booth,pa4atten,headphones)

if nargin < 2
   help findmaxlevel
   return
elseif nargin < 3
   headphones = 'HD650';
end


switch booth
case {'n640','N640'} % No TDT
    maxout = 103.5;
    switch headphones
        case 'HD580'
        case 'HD650'
            maxout = maxout + 0.8;
        case 'ER2'
            maxout = maxout - 14.7;
        case 'EAR3A'
            maxout = maxout + 3.0;
        otherwise
            error('headphone type not recognized')
    end
case 'crown3'
    maxout = 103.5 + 12.2 - 1.35;   %This is valid for Channel 1 (left ear). Right ear is 1.35 dB higher
    switch headphones
        case 'HD580'
        case 'HD650'
            maxout = maxout + 0.8;
        case 'ER2'
            maxout = maxout + 0.35;
        otherwise
            error('headphone type not recognized')
    end

case 'crownmax'
    maxout = 103.5 + 28.7;   %Valid for both channels
    switch headphones
        case 'HD580'
        case 'HD650'
            maxout = maxout + 0.8;
        case 'ER2'
            maxout = maxout + 0.35;
        otherwise
            error('headphone type not recognized')
    end
    
case {'n640_1','N640_1'} % with TDT
    maxout = 105.8;
    switch headphones
        case 'HD580'
        case 'HD650'
            maxout = maxout + 0.8;
        case 'ER2'
            maxout = maxout - 0.9;
        otherwise
            error('headphone type not recognized')
    end
case 'ci1' % with TDT
    maxout = 105.13;
    switch headphones
        case 'HD580'
        case 'HD650'
            maxout = maxout + 0.8;
        case 'ER2'
            maxout = maxout - 0.9;
        otherwise
            error('headphone type not recognized')
    end

case 'booth7' % Loudspeaker with Crown Amp (3/9/17)
%    maxout = 113;   %A wideband noise at -25dB rms produces 91 dBSPL, so a tone with a peak of 1 (-3dB rms) would produce 22dB more.
    maxout = 99;   %A wideband noise at -20dB rms produces 82 dBSPL, so a tone with a peak of 1 (-3dB rms) would produce 17dB more.

case 'test'
   maxout = 103.5;
	switch headphones
	case 'HD580'
    case 'HD650'
            maxout = maxout + 0.8;
	case 'ER2'
	   maxout = maxout - 7;
	otherwise
 	  error('headphone type not recognized')
	end
otherwise
   error('booth not recognized')
end

if isstr(pa4atten)
   atten = str2num(pa4atten);
else
   atten = pa4atten;
end

maxlevel = maxout - atten;

%  ER2's produce 16.7 dB less voltage when connected directly to the Lynx22
%  soundcard, and 2.9 dB less voltage when connected via the TDT headphone
%  buffer (HB7).
%  
%  the front, back, mid, and white booths, respectively, than
%  do the HD580s.  However, they are supposed to be 2 dB more sensitive
%  (100 dB SPL @ 1V rms vs. 98 dB SPL @ 1V), giving an overall
%  difference of e.g., 14.7 dB (n640) and 0.9 dB (n640_1).
%eof
