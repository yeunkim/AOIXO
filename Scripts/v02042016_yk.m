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

fn = 'VIDS.xlsx';
fnpath = '/Users/yeunkim/Dropbox/AOIXI/Videos/';

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
[~,~,data] = xlsread([fnpath '/' fn],1,'A1:I9');  % read the data
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
stim5 = data(2:end,8);
stim6 = data(2:end,9);

%% update stim filenames by appending fnpath
% to each of the stim1, stim2, stim3, stim4
stim1 = fullfile(fnpath,stim1);
stim2 = fullfile(fnpath,stim2);
stim3 = fullfile(fnpath,stim3);
stim4 = fullfile(fnpath,stim4);
stim5 = fullfile(fnpath,stim5);
stim6 = fullfile(fnpath,stim6);

%% now construct the blocks cell array
blocknumber = length(block);  % how many rows we will have
blocks = [stim1 stim2 stim3 stim4 stim5 stim6 color type];

%% print the output
%blocks

%% generate coordinates (6 sections)
% allcoords = coordgenerater_vid(res.width, res.height, buffer);
allcoords = coordgenerator(res.width, res.height, buffer);

load('rand_coords.mat');

%% preallocate array for cue start times and cue time duration
cuestartimes = zeros(1,8);
cuetimedur = zeros(1,8);
vidtimes = zeros(8,6);
%photoendtime = zeros(8,6);
blockdurs = zeros(1,8);
blocktotaltime = zeros(1,8);

%% Display Videos
for blocknumber = 1:8
    %Frame color
    col = eval(blocks{blocknumber,7});
    
    %Movie File Names
    moviefiles = blocks(blocknumber,1:6);
    
    
    randloc = [];
    for i = 1:6
        Screen('FrameRect', window, col, wsize, framew);
        
        %set jitter time for cue ---- megha suggested 5-6 seconds
        %cuetime = 1.5;
        %set seed for pseudorandom generation
        rng(blocknumber * i);
        cuetime = randi(5); %could be till 6
        
        %Set cue trial
        if i == 1
            if strcmp((blocks(blocknumber,8)), 'point') %if in column 6 it says point it should generate a dot cue on the screen
                path='~/Dropbox/AOIXI/Images/pointer.png';
                theImage = imread(path);
                imageTexture = Screen('MakeTexture', window, theImage);
                Screen('DrawTexture', window, imageTexture, [], [], 0);
                
            end
            
            if strcmp((blocks(blocknumber,8)), 'grasp1') %grasp1 = large object
                path='~/Dropbox/AOIXI/Images/grab.png';
                theimage = imread(path);
                imageTexture = Screen('MakeTexture', window, theimage);
                Screen('DrawTexture', window, imageTexture, [], [], 0)
            end
            
            if strcmp((blocks(blocknumber,8)), 'grasp2') %grasp2 = small objects
                path='~/Dropbox/AOIXI/Images/pinch.png';
                theimage = imread(path);
                imageTexture = Screen('MakeTexture', window, theimage);
                Screen('DrawTexture', window, imageTexture, [], [], 0)
            end
            
            %write cue start times to text file
            stcue_system = GetSecs;
            stcue = stcue_system - exp_st;
            cuestartimes(blocknumber) = stcue;
            
            Screen('Flip', window);
            WaitSecs(cuetime);
            
            %write cue duration to text file
            
            cuedur = GetSecs - stcue_system;
            cuetimedur(blocknumber) = cuedur;
            stblock = GetSecs;
            start = stblock - exp_st; %experiment time, i was subtracting out system
            
        end
        
        randloc=[randloc; round(allcoords(r(i+(6*(blocknumber-1))),1:4))];
        
    end
    
    VidPlayback2;
    
    blockdur = GetSecs - stblock; % block dur (not counting cue)
    blocktot = blockdur + cuedur;
    blockdurs(blocknumber) = blockdur;
    blocktotaltime(blocknumber) = blocktot;
    
    
    %Wait 12 seconds
    then = GetSecs;
    wait = 0;
    
    while wait < 12
        [HitKey secs KeyCode] = KbCheck;
        if KeyCode(esc)
            ListenChar(0);
            sca;
        end
        wait = GetSecs-then;
    end
end

M = {cuestartimes; cuetimedur; blockdurs; blocktotaltime};
tM = transpose(cell2mat(M));

if exist(blockfn, 'file') == 2,
    dlmwrite(blockfn,tM,'-append');
else
    writeoutcsv(blockfn, tM, 'block');
end;

ListenChar(0);
% sca;



