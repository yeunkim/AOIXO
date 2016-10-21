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

fn = 'greenmovie1.xlsx';
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


%% update stim filenames by appending fnpath
% to each of the stim1, stim2, stim3, stim4
stim1 = fullfile(fnpath,stim1);
stim2 = fullfile(fnpath,stim2);


%% now construct the blocks cell array
blocknumber = length(block);  % how many rows we will have
blocks = [stim1 stim2  color type];

%% print the output
%blocks

%% Display Videos
for blocknumber = 1:3;
    %Frame color
    col = blue;
    
    %Movie File Names
    moviefiles = blocks(blocknumber,1:2);
    
    
    randloc = [];
    for i = 1:2
        Screen('FrameRect', window, col, wsize, framew);
        %Set cue trial
        if i == 1
         Screen('FrameRect', window, col, wsize, framew);
            if strcmp((blocks(blocknumber,4)), 'point') %if in column 6 it says point it should generate a dot cue on the screen 
                  path='~/Dropbox/AOIXI/Images/pointer.png';
                  theImage = imread(path);
                  imageTexture = Screen('MakeTexture', window, theImage);
                  Screen('DrawTexture', window, imageTexture, [], [], 0); 
                 
                   
            end
            
            if strcmp((blocks(blocknumber,4)), 'grasp1')
                  path='~/Dropbox/AOIXI/Images/pinch.png';
                  theimage = imread(path);
                  imageTexture = Screen('MakeTexture', window, theimage);
                  Screen('DrawTexture', window, imageTexture, [], [], 0)
                 
            end 
            
            if strcmp((blocks(blocknumber,4)), 'grasp2')
                  path='~/Dropbox/AOIXI/Images/grab.png';
                  theimage = imread(path);
                  imageTexture = Screen('MakeTexture', window, theimage);
                  Screen('DrawTexture', window, imageTexture, [], [], 0) 
            
            end 

            
            cuetime = 1.5;
            
            
            Screen('Flip', window);
            WaitSecs(cuetime);
            
            
        end
            xvid = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
            yvid = randi(floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)]));
            randloc = [randloc; CenterRectOnPoint(halfpic, xvid, yvid)];
                      
    end
    
        vidtut;
    
  
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



