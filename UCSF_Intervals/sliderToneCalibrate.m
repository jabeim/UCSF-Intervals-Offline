function sliderToneCalibrate(id,tag,allFreqs,fig)
%% initial static parameters

htmlSource = '/web/catss/Audio/webAudioPlayer.html';                % for use on MLWA Server
writePath = '/web/catss/Audio/';                                    % for use on MLWA Server
dataPath = '/labs/oxenhamlab/ToneCalibration/';                     % for use on MLWA Server


% dataPath = 'C:\Users\Jbeim\OneDrive\Documents\MATLAB\local scripts\Online Experiments\';                           % local testing
% writePath = 'C:\Users\Jbeim\OneDrive\Documents\MATLAB\local scripts\Online Experiments\';
% htmlSource = 'C:\Users\Jbeim\OneDrive\Documents\MATLAB\local scripts\Online Experiments\webAudioPlayer.html';


toneParams.allFreqs = allFreqs;
toneParams.levelRange = 60;
toneParams.fs = 44100;
toneParams.toneDur = 300;
toneParams.gapDur = 100;
toneParams.rampDur = 10;
toneParams.t = 0:1/toneParams.fs:toneParams.toneDur/1000-1/toneParams.fs;


levels = zeros(1,length(toneParams.allFreqs));
%% Construct new figure elements
previousGui = fig.Children;
windowSize = repmat(fig.Position(3:end),1,2);
delete(previousGui)

msgpanel = uitextarea(fig,...
    'Value','Loading please wait...',...
    'FontSize',18,...
    'FontWeight','bold',...
    'HorizontalAlignment','center',...
    'Editable','off',...
    'BackgroundColor',[.9 .9 .9],...
    'Position',[.1 .85 .8 .125].*windowSize...
    );


webAudioPlayer = uihtml...
    ('Parent',fig,...
    'Visible','off',...
    'HTMLSource',htmlSource,...
    'Interruptible','off',...
    'Position',[0.01 0.8333 1.0000 0.1667].*windowSize,...,
    'DataChangedFcn',@(src,event)webAudioChange(src,event)...
    );

pause(1)

if isempty(webAudioPlayer.Data)
    webAudioPlayer.Data = {-1};
    waitfor(webAudioPlayer,'Data',0);
end

msgpanel.Value = {'Click "Play All" as many times as you want and use the sliders to adjust the tones so that they are the same loudness.',...
    'Once you are satisfied the tones are equally loud, press "save/quit" to move on to the experiment.'};



playbutton = uibutton(fig,...
    'Text','Play All',...
    'Interruptible','off',...
    'BusyAction','cancel',...
    'Position',[0.2 0.1 0.25 0.05].*windowSize,...
    'ButtonPushedFcn',{@playTones,1:length(toneParams.allFreqs),toneParams});

savequitbutton = uibutton(fig,...
    'Text','Save/Quit',...
    'Interruptible','off',...
    'BusyAction','cancel',...
    'Position',[0.5 0.1 0.25 0.05].*windowSize,...
    'ButtonPushedFcn',{@closeFcn});
    
% Level adjustment sliders and individual playback buttons
for s = 1:length(toneParams.allFreqs)
   sld(s) = uislider(fig,'Limits',[-toneParams.levelRange/2 toneParams.levelRange/2],...
       'Orientation','vertical',...
       'MajorTicks',[-30 -20 -10 0 10 20 30],...
       'Position',[0.05+(s-1)/length(toneParams.allFreqs) 0.3 3/windowSize(3) 0.5].*windowSize...
        );
   btn(s) = uibutton(fig,...
       'Text',num2str(s),...
       'Interruptible','off',...
       'BusyAction','cancel',...
       'Position',[0.05+(s-1)/length(toneParams.allFreqs)*.975 0.2 0.5/length(toneParams.allFreqs) 0.05].*windowSize,...
       'ButtonPushedFcn',{@playTones,s,toneParams}...
       );
end



%% callbacks
function playTones(app,event,testFreqs,toneParams)
stim = [];

for i = testFreqs
    levelAdjustment = -5-toneParams.levelRange/2+sld(i).Value;
    stim = [stim hann(10^(levelAdjustment/20)*sin(2*pi*toneParams.allFreqs(i)*toneParams.t),10,toneParams.fs) zeros(1,toneParams.gapDur/1000*toneParams.fs)];
end

audioFileName = [id '_' datestr(now,'YYYYmmDD_hhMMss') '.wav'];
audiowrite([writePath audioFileName],stim,toneParams.fs);
pause(.05)
webAudioPlayer.Data = {0,audioFileName};                     % stage audio file within HTML
waitfor(webAudioPlayer,'Data',1); 
webAudioPlayer.Data = {2};  
pause(.015)

% sound(stim,toneParams.fs)



originalColor = btn(1).BackgroundColor;
for i = testFreqs
    btn(i).BackgroundColor = [1 0 0];
    pause(toneParams.toneDur/1000)
    btn(i).BackgroundColor = originalColor;
    pause(toneParams.gapDur/1000);
end
waitfor(webAudioPlayer,'Data',4)
delete([writePath audioFileName])
end

function closeFcn(app,event)    
for i = 1:length(sld)
    levels(i) = sld(i).Value;
end

save([dataPath id '_' tag '.mat'],'levels','allFreqs')

msgpanel.Value = 'Your Data has been saved.';
pause(1)

delete(msgpanel)
delete(playbutton)
delete(btn)
delete(sld)
delete(savequitbutton)

fig.UserData = 0;
end

end
