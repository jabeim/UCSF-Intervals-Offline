function webAudioChange(src,event)
% display data exchange status between MATLAB and HTML code. primarily used
% in debugging. Status codes will print to the console/web experiment log.
% Status codes:
%   1: Audio has buffered until the html event: canplaythrough fires.
%   3: Audio playback has started
%   4: Audio playback has ended
%
%   999: html module webAudioPlayer has been supplied with invalid data.

% disp(event.Data)
