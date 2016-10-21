%% 'Final 2.0' version script to play stimulus videos; Dystonia MRI

% Project Directory
% Change as needed based on location of MATLAB modules/files

close all;

projdir = '~/Dropbox/AOIXI/';

%% PTB Settings
% Prepare imaging pipeline for some fitting work:
PsychImaging('PrepareConfiguration');
screenID = max(Screen('Screens'));
res = Screen('Resolution', screenID);
PsychTweak('UseGPUIndex', 1);
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);

% Set the size of the framebuffer:
fitSize = [res.width, res.height];

% Center small framebuffer inside big framebuffer:
PsychImaging('AddTask', 'General', 'UsePanelFitter', fitSize, 'Centered');

%% Setup Windows and initial variables
% Dot Size
dsize = 30;
% Dot Radius
drad = dsize/2;

%set values for colors
black = [0 0 0];
white = [254 254 255];
green = [0 255 127];
blue = [28 134 238];
violet = [255 131 250];
orange = [255 140 0];
yellow = [255 255 0];
red = [255 0 0];

%set function of keys on keyboard
KbName('UnifyKeyNames');
esc = KbName('ESCAPE');

 %set window variable and text properties
    [window, wsize] = PsychImaging('OpenWindow', screenID, white); %this opens a window 
    HideCursor; %Pretty obvious...
    ListenChar(2); %Suppresses keyboard input from going into the environment outside of the PTB screen
    
    %get rect object with screen size
    sz = [];
    [cx, cy] = RectCenterd(wsize);
    framew = 40;
    buffer = 15 + framew;
    halfpic = [0, 0, wsize(3)/2, (wsize(3)*.5625)/2];
    halfwin = CenterRectOnPoint(halfpic, cx ,cy);
     
  while 1
     [hitkey, ~, keycode] = KbCheck(-1); % tilde is weird    
     if strcmp(KbName(keycode), 't')
         break
     end
  end
  
  
  %phototrial
  
  greenvideo1
  greenphoto1
  bluevideo1
  bluephoto1
  %greenvideo2
 % greenphoto2
  %bluevideo2
  %bluephoto2
  
  %close open items and finish
    ListenChar(0);
    sca
    return;
    
