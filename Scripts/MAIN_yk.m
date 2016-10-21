
%% 'Final 2.0' version script to play stimulus videos; Dystonia MRI

% Project Directory
% Change as needed based on location of MATLAB modules/files

close all;
clear all;


projdir = '~/Dropbox/AOIXI/';
%filedir = '~/Dropbox/AOIXI/outputfiles';

%% PTB Settings
% Prepare imaging pipeline for some fitting work:
PsychImaging('PrepareConfiguration');
screenID = max(Screen('Screens')); % screenID is maximum dimension of the screen
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

rng shuffle

%% Execute
try
    
    
    fids = inputdlg('Please enter ID number.', 'ID Number', 1);
    %fid = double(fids);
    cd(projdir);
    files = dir('block_ts*.txt');
    files = {files.name};
    used_fids = strrep(files,'block_ts','');
    used_fids = strrep(used_fids,'.txt','');
    
    for i = 1:length(used_fids)
        if strcmp(fids, used_fids(i))
            error('Error: ID has already been used.');
        end
    end
    
    %set window variable and text properties
    [window, wsize] = PsychImaging('OpenWindow', screenID, white); %this opens a window 
    HideCursor; %Pretty obvious...
    ListenChar(2); %Suppresses keyboard input from going into the environment outside of the PTB screen
    
    %get rect object with screen size
    sz = [];
    [cx, cy] = RectCenterd(wsize);
    framew = 35;
    buffer = 15 + framew;
    halfpic = [0, 0, wsize(3)/2, (wsize(3)*.5625)/2];
    halfwin = CenterRectOnPoint(halfpic, cx ,cy);
     
  
    
    %% output block start times to text file

    %open file to write to; if a previous document has been
    %left in folder, not moved, or is not empty for some reason,
    %a newline character will be placed between previous data and
    %currently acquired data
    
    blockfn = cell2mat([projdir, 'block_ts', fids, '.csv']);
    photofn = cell2mat([projdir, 'phototimes', fids, '.csv']);
    
    %Open a file to record all video times 
      vtimefn = cell2mat([projdir, 'time_ts', fids, '.txt']);
      fidvtime = fopen(vtimefn, 'a');
    
        if (~fread(fidvtime))
            fprintf(fidvtime, '\n');
        end
    
      fclose(fidvtime);
    
    
     exp_st = GetSecs;
    
    % t = 23
     while 1
      [hitkey, secs, keycode] = KbCheck(-3); 
       if (keycode(23));
           break
     
        end
     end
     
     triggertime0 = GetSecs;
    
    
        
    %function that displays pictures
    p02102016_yk
    
    %function that plays videos
    v02042016_yk
    
    
    Screen('Flip', window);
    WaitSecs(12);
    
    
    while 1
      [hitkey, secs, keycode] = KbCheck(-3); 
       if (keycode(23));
           triggertime1 = secs;
           break
     
        end
    end
     
     while 1
      [hitkey, secs, keycode] = KbCheck(-3); 
       if (keycode(23));
           triggertime2 = secs;
           break
     
        end
     end
     
     while 1
      [hitkey, secs, keycode] = KbCheck(-3); 
       if (keycode(23));
           triggertime3 = secs;
           break
     
        end
     end
    
    time = GetSecs;
    wholetime =  GetSecs - exp_st;
    fidvtime = fopen(vtimefn, 'a');
    fprintf(fidvtime, 'times %.4f\n', wholetime, triggertime0,...
        triggertime1, triggertime2, triggertime3);
    fclose(fidvtime);
    
    
    
    %close open items and finish
    ListenChar(0);
    sca
    return;
    
%% error checking; close windows on error
catch ME
    disp(ME)
    ME.stack(1)
    ListenChar(0);
    sca
end
