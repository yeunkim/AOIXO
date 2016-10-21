function aoixi(runtype)
% aoixi - program to run aoixi mri program for wu lab
% usage:
% aoixi(runtype)
% runtype = 1, =2
% 1/21/16

% /Users/jessicapasquaadmin/Dropbox/AOIXI/Scripts

% check the parameter
%if nargin < 1,
    %disp('you need to run aoixi(runtype)')
    %help aoixi
    %return
end

%%   
 % 1 = imagine/execute; 2 = imitate/observe

% main stuff here
MAIN
PicSetup3
ShowPics2
VidSetup3


function MAIN

%% 'Final 2.0' version script to play stimulus videos; Dystonia MRI

% Project Directory
% Change as needed based on location of MATLAB modules/files

close all;
clear all;

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
     
  while 1
     [hitkey, ~, keycode] = KbCheck(-1); % tilde is weird    
     if strcmp(KbName(keycode), 't')
         break
     end
  end
    
    %% output block start times to text file
    exp_st = GetSecs;

    %open file to write to; if a previous document has been
    %left in folder, not moved, or is not empty for some reason,
    %a newline character will be placed between previous data and
    %currently acquired data
    blockfn = cell2mat([projdir, 'block_ts', fids, '.txt']);
    
    fidblock = fopen(blockfn, 'a');
    
    if (~fread(fidblock))
        fprintf(fidblock, '\n');
    end
    
    fclose(fidblock);
    
    %open file in which to write cue times
    cuefn = cell2mat([projdir, 'cue_ts', fids, '.txt']);
    
    fidcue = fopen(cuefn, 'a');
    
    if (~fread(fidcue))
        fprintf(fidcue, '\n');
    end
    
    fclose(fidcue);
    
    %Opens a .txt for the location of the photos 
    xypicsfn = cell2mat([projdir, 'xypics_ts', fids, '.txt']);
    
    xypicsid = fopen(xypicsfn, 'a');
        if(~fread(xypicsid))
            fprintf(xypicsid, '\n');
        end
    fclose(xypicsid);
    
    %Opens a .txt for the location of the videos 
    xyvidsfn = cell2mat([projdir, 'xyvids_ts', fids, '.txt']);
    
    xyvidsid = fopen(xyvidsfn, 'a');
        if(~fread(xyvidsid))
            fprintf(xyvidsid, '\n');
        end
    fclose(xyvidsid);
     
    %function that displays pictures
    %PicSetup3;
    
    %function that plays videos
    VidSetup3;
    
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

%%######################PIC SETUP########################################
function PicSetup3
% readstimorder script
% awu 11/5/15
%
% reads in an excel file for the aoixi project
% excel file contains order of stimuli
% structure of excel file
% line 1: header
% column 1: block #
% column 2: type ('grasp' or 'point')
% column 3: color (frame color string 'blue', 'green', etc)
% columns 4-8: filename for the stimulus to present


%% 'Final 2.0' Show Pics
%runtype = 'pseudorandom'; % 'pseudorandom', 'fixed'

%% initialize loop variables
iteration = 0;
abort = 0;
count = 1;
info = [];

green = [0 255 127]; % this is defined in the main script but put it here for trouble shooting purposes 
blue = [28 134 238];

%
%fn = 'filename.xls';
%fnpath = '/User...etc';

%% first get a filename for an excel file
%[fn,fnpath] = uigetfile({'*.xlsx';'*.xls'},...
   %'Select excel file with stimuli');

fn = '_Photo_Permutations.xlsx';
fnpath = '~/Dropbox/AOIXI/Images';

if isequal(fn,0) || isequal(fnpath,0),
    disp('cancelled.');
    return
end

%% load excel data
% fn = filename
% fnpath = folder path (assume pic/vid files are here too)
curpath = pwd;  % save current folder (in case useful later
disp(sprintf('Reading: ''%s''',fullfile(fnpath,fn)));
% import the table
cd(fnpath);  % go to folder
data = readtable(fn);  % read the data
cd(curpath);  % back to original folder
format compact
% summary(data)
varnames = data.Properties.VariableNames;

%% assume varnames are
% block, type, color, stim1, stim2, stim3, stim4
block = data.block; % vector of block numbers
type = data.type; % cell array of strings
color = data.color;
stim1 = data.stim1;
stim2 = data.stim2; 
stim3 = data.stim3;
stim4 = data.stim4;

%% update stim filenames by appending fnpath
% to each of the stim1, stim2, stim3, stim4
stim1 = fullfile(fnpath,stim1);
stim2 = fullfile(fnpath,stim2);
stim3 = fullfile(fnpath,stim3);
stim4 = fullfile(fnpath,stim4);

%% now construct the blocks cell array
blocknumber = length(block);  % how many rows we will have
blocks = [stim1 stim2 stim3 stim4 color type];

%% print the output
%blocks

%% Display Pics
escapenumber = KbName('escape');
for blocknumber = 1:12 %in the old script there were 24 blocks but now there are 12

    %Frame color
 
    col = eval(blocks{blocknumber,5}); %5 refers to the color column, should read out the value for green/blue
    
    %Picture File Names
    picfiles = blocks(blocknumber,1:4); %so this line basically says to  read rows 1-12 col 1-4 and calls them picfiles 
    
    %display a block of 3 pictures
    %if noptbflag == 1,
        %disp(sprintf('block # %d',blockno));
        %disp('ShowPics runs here and 10 sec will pass.');
    %else
        ShowPics2;

    
    %Wait 10 seconds
    then = GetSecs;
    wait = 0;
    while wait < 10
        [HitKey secs KeyCode] = KbCheck;
        if find(KeyCode) == escapenumber,
            ListenChar(0);
            sca;
        end
        wait = GetSecs-then;
    end  
end

ListenChar(0);

%%%%%%%%%%%%%%%%%SHOW PICS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ShowPics2

%% 'Final 2.0' ShowPics.m
%blocks(1,1:4) is first row of photos
% Load pictures into variable and display for 3 seconds


for i=1:4
    %Screen('FrameRect', window, col, wsize, framew);
    
    picname=picfiles{min(i, length(picfiles))};
    img = imread(picname, 'png'); %when I check the script it does name an image file so not sure why its not popping up.
   
    %Set cue trial
    if i == 1      
        Screen('FrameRect', window, col, wsize, framew);
        if strcmp((blocks(blocknumber,6)), 'point') %if in column 6 it says point it should generate a dot cue on the screen 
            dotx = randi([framew+drad, wsize(3)-framew-drad]);
            doty = randi(floor([framew+drad, wsize(4)-framew-drad]));
            Screen('DrawDots', window, [dotx; doty], dsize, black, [], 1);
            %Screen('TextSize', window, 300);
            %text = sprintf('.'); 
            %DrawFormattedText(window, text, dotx, doty, black);
       end
        
        %set jitter time for cue
        cuetime = 2*rand() + 1;
        
        %write cue start times to text file
        fidcue = fopen(cuefn, 'a'); %has a problem with this line b/c cuefn is defined in main_v2
        stcue = GetSecs;
        fprintf(fidcue, '%.4f\t', stcue - exp_st);
        fclose(fidcue);
        
        Screen('Flip', window); %also has a problem here
        WaitSecs(cuetime);
        
        %write cue duration to text file
        fidcue = fopen(cuefn, 'a');
        cueend = GetSecs - stcue;
        fprintf(fidcue, '%.4f %d\n', cueend, 1);
        fclose(fidcue);
        
        %write block start times to text file
        fidblock = fopen(blockfn, 'a');
        stblock = GetSecs;
        fprintf(fidblock, '%.4f\t', stblock - exp_st);
        fclose(fidblock);
    
        
    end
    
    % Generate variables to randomly place a completely visible rectangle
    % on the screen for each iteration of the loop. The rectangle will lie
    % somewhere between the buffer areas (as defined by the frame) and will
    % fully accommodate the image to be placed therein wihtout clipping any
    % of it.
    
    xpic(i) = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
    ypic(i) = randi(floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)]));
 
    randloc = CenterRectOnPoint(halfpic, xpic(i), ypic(i));
    
            for i == 1; %probably won't work 
                xypicsid = fopen(xypicsfn, 'a');
                xloc = xpic;
                yloc = ypic;
                printf(xypicsid,'%.4f %d\n', xloc, yloc);
                fclose(xypicsid);
            end
    
           
    
    %% Check for abortion by user:
    abortit = 0;
    [keyIsDown,secs,keyCode]=KbCheck;
    if (keyCode(esc))
        % Set the abort-demo flag.
        ListenChar(0);
        sca;
        abortit = 2;
        break
    end
    if abortit == 2
        sca
        break
    end
    
    %Display Picture for 3 seconds
    Screen('FrameRect', window, col, wsize, framew);
    Screen('PutImage', window, img, randloc);
    Screen('Flip', window);
    WaitSecs(2.5);
 end

%record block duration
fidblock = fopen(blockfn, 'a');
blockend = GetSecs - stblock;
%fprintf(fidblock, '%.4f %d\n', blockend, 1);
fprintf(fidblock, '%.4f %d %d %d %d %d %d %d %d %d\n', blockend, 1,...
    xpic(1),ypic(1),xpic(2),ypic(2),xpic(3),ypic(3),xpic(4),ypic(4));
fclose(fidblock);

% End of playback - clear last picture:
Screen('Flip', window);


%% ################### VidSetup3 ####################
% describe
function VidSetup3
% readstimorder script
% awu 11/5/15
%
% reads in an excel file for the aoixi project
% excel file contains order of stimuli
% structure of excel file
% line 1: header
% column 1: block #
% column 2: type ('grasp' or 'point')
% column 3: color (frame color string 'blue', 'green', etc)
% columns 4-8: filename for the stimulus to present


%% 'Final 2.0' Show Pics
%runtype = 'pseudorandom'; % 'pseudorandom', 'fixed'

%% initialize loop variables
iteration = 0;
abort = 0;
count = 1;
info = [];

green = [0 255 127]; % this is defined in the main script but put it here for trouble shooting purposes 
blue = [28 134 238];

%
%fn = 'filename.xls';
%fnpath = '/User...etc';

%% first get a filename for an excel file
%[fn,fnpath] = uigetfile({'*.xlsx';'*.xls'},...
   %'Select excel file with stimuli');

fn = 'Rvids.xlsx';
fnpath = '/Users/jessicapasquaadmin/Dropbox/AOIXI/Videos/';

if isequal(fn,0) || isequal(fnpath,0),
    disp('cancelled.');
    return
end


%% load excel data
% fn = filename
% fnpath = folder path (assume pic/vid files are here too)
curpath = pwd;  % save current folder (in case useful later
disp(sprintf('Reading: ''%s''',fullfile(fnpath,fn)));
% import the table
cd(fnpath);  % go to folder
[~,~,data] = xlsread([fnpath '/' fn],1,'A1:G13');  % read the data
cd(curpath);  % back to original folder
format compact
% summary(data)
varnames = data(1,:);

%% assume varnames are
% block, type, color, stim1, stim2, stim3, stim4
block = data(2:end,1); % vector of block numbers
type = data(2:end,2); % cell array of strings
color = data(2:end,3);
stim1 =data(2:end,4);
stim2 = data(2:end,5); 
stim3 = data(2:end,6);
stim4 = data(2:end,7);

%% update stim filenames by appending fnpath
% to each of the stim1, stim2, stim3, stim4
stim1 = fullfile(fnpath,stim1);
stim2 = fullfile(fnpath,stim2);
stim3 = fullfile(fnpath,stim3);
stim4 = fullfile(fnpath,stim4);

%% now construct the blocks cell array
blocknumber = length(block);  % how many rows we will have
blocks = [stim1 stim2 stim3 stim4 color type];

%% print the output
%blocks

%% Display Videos
for blocknumber = 1:12
    %Frame color
    col = eval(blocks{blocknumber,5});
    
    %Movie File Names
    moviefiles = blocks(blocknumber,1:4);
    
    
    randloc = [];
    for i = 1:4
        Screen('FrameRect', window, col, wsize, framew);
        %Set cue trial
        if i == 1
            if strcmp((blocks(blocknumber,6)), 'point')
                dotx = randi([framew+drad, wsize(3)-framew-drad]);
                doty = randi(floor([framew+drad, wsize(4)-framew-drad]));
                Screen('DrawDots', window, [dotx; doty], dsize, black, [], 1);
                %Screen('TextSize', window, 30);
                %text = sprintf('.'); 
                %DrawFormattedText(window, text, dotx, doty, black);
            end

            %set jitter time for cue
            cuetime = 2*rand() + 1;
            
            if i == 1
                %write cue start times to text file
                fidcue = fopen(cuefn, 'a');
                stcue = GetSecs;
                fprintf(fidcue, '%.4f\t', stcue - exp_st);
                fclose(fidcue);
            end
            
            Screen('Flip', window);
            WaitSecs(cuetime);
            
            %write cue duration to text file
            if i == 1
                fidcue = fopen(cuefn, 'a');
                cueend = GetSecs - stcue;
                fprintf(fidcue, '%.4f %d\n', cueend, 1);
                fclose(fidcue);
            end
            
            %record block start time to text file
            fidblock = fopen(blockfn, 'a');
            stblock = GetSecs;
            fprintf(fidblock, '%.4f\t', stblock - exp_st);
            fclose(fidblock);

        end
            xvid = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
            yvid = randi(floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)]));
            randloc = [randloc; CenterRectOnPoint(halfpic, xvid, yvid)];
            
            for i = 1; %this actually works!!!! 
                xyvidsid = fopen(xyvidsfn, 'a');
                xloc = xvid;
                yloc = yvid;
                fprintf(xyvidsid,'%.4f %d\n', xloc, yloc);
                fclose(xyvidsid);
            end
    end
    
    VidPlayback2;
    
    %record block duration
    fidblock = fopen(blockfn, 'a');
    blockend = GetSecs - stblock;
    fprintf(fidblock, '%.4f %d\n', blockend, 1);
    fclose(fidblock);
    
    %Wait 10 seconds
    then = GetSecs;
    wait = 0;
   
    while wait < 10
        [HitKey secs KeyCode] = KbCheck;
        if KeyCode(esc)
            ListenChar(0);
            sca;
        end
        wait = GetSecs-then;
    end 
end

ListenChar(0);
sca;

function VidPlayback2
%% 'Final 2.0' VidPlayback.m

abortit = 0;

% Playbackrate defaults to 1:
rate=1;

% Load first movie. This is a synchronous (blocking) load:
iteration = 1;
%moviename = [pwd filesep 'Tweezers_Pinch.mp4']
moviename=moviefiles{min(iteration, length(moviefiles))};
[movie movieduration fps imgw imgh] = Screen('OpenMovie', window, moviename);

% Start playback of movie. This will start
% the realtime playback clock and playback of audio tracks, if any.
% Play 'movie', at a playbackrate = rate, with 1.0 == 100% audio volume.
Screen('PlayMovie', movie, rate, 0, 1.0);

prefetched = 0;
lastpts = -1;

% Endless loop, runs until ESC key pressed:
while abortit < 2
    
    
    % Generate variables to randomly place a completely visible rectangle
    % on the screen for each iteration of the loop. The rectangle will lie
    % somewhere between the buffer areas (as defined by the frame) and will
    % fully accommodate the video to be placed therein without clipping any
    % of it. 
    
    % Show basic info about next movie: Only the name, as we cannot access
    % other info (fps, duration, width and height) for all successor movies.
    % Not a big deal, as all properties have to match the known properties of
    % the first opened movie anyway - except for moviename and duration...
    
    i=0;
  
    % Get moviename of next file (after the one that is currently playing):
    
    iteration=iteration + 1;
    moviename=moviefiles{min(iteration, length(moviefiles))};
    t1 = GetSecs;

    
    % Playback loop: Fetch video frames and display them...
    while 1
        i=i+1;
        if abs(rate) > 0
            % Return next frame in movie, in sync with current playback
            % time and sound.
            % tex either the texture handle or zero if no new frame is
            % ready yet. pts = Presentation timestamp in seconds.
            [tex pts] = Screen('GetMovieImage', window, movie, 1);
            
            % Valid texture returned?
            if tex < 0
                % No. This means that the end of this movie is reached.
                % This can't really happen, unless something went wrong
                % during playback, because we play all movies round-robin
                % completely seamless.
                break
            end
            
            if tex > 0
                
                % Yes. Draw the new texture immediately to screen:
                Screen('FrameRect', window, col, wsize, framew);
                Screen('DrawTexture', window, tex, sz, randloc(iteration-1,:));
                
                % Update display:
                ft = Screen('Flip', window);
                % Release texture:
                Screen('Close', tex);
            end
        end
        
        % Check for abortion by user:
        abortit = 0;
        [keyIsDown,secs,keyCode]=KbCheck;
        if (keyCode(esc))
            % Set the abort-demo flag.
            ListenChar(0);
            sca;
            abortit = 2;
            break
        end
        if abortit == 2
            sca;
            break
        end
        
        % We queue the next movie for playback, immediately
        % after start of playback of the current movie, as indicated
        % by the > 0 presentation timestamp:
        if prefetched==0 && pts > 0
            % Queue for background async load operation:
            % We simply set the async flag to 2 and don't query any
            % return values. We pass in the 'movie' handle of the movie
            % which should be succeeded by the new movie 'moviename':
            Screen('OpenMovie', window, moviename, 2, movie);
            prefetched=1;
        end
        
        % Detect when the followup movie has started playback. We detect
        % the change due to a wraparound of the presentation timestamp:
        if prefetched==1 && pts < lastpts
            % New movie has started. Do a new outer-loop iteration to
            % select a new moviefile as successor:
            prefetched = 0;
            lastpts = -1;
            break
        end
        
        % Keep track of playback time:
        lastpts = pts;
    end
    
    % Print some stats about last played movie:
    telapsed = GetSecs - t1;
    finalcount=i;
    
    % As playback of the new movie has been started already, we can
    % simply reenter the playback loop:
    if iteration > length(moviefiles)
        break
    end
end

% End of playback - stop & close the movie:
Screen('Flip', window);
Screen('PlayMovie', movie, 0);
Screen('CloseMovie', movie);


