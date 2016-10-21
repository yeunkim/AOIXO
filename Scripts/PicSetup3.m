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
        %ShowPics2;
        
 randloc = [];
    for i=1:4
    Screen('FrameRect', window, col, wsize, framew); %can switch w/ below 
    
    %picname=picfiles{min(i, length(picfiles))};
    %img = imread(picname, 'png'); %when I check the script it does name an image file so not sure why its not popping up.
   
    %Set cue trial
    if i == 1      
        %Screen('FrameRect', window, col, wsize, framew);
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
       if i == 1 
        fidcue = fopen(cuefn, 'a'); %has a problem with this line b/c cuefn is defined in main_v2
        stcue = GetSecs;
        fprintf(fidcue, '%.4f\t', stcue - exp_st);
        fclose(fidcue);
       end 
        
        Screen('Flip', window); %also has a problem here
        WaitSecs(cuetime);
        
        %write cue duration to text file
        if i == 1
        fidcue = fopen(cuefn, 'a');
        cueend = GetSecs - stcue;
        fprintf(fidcue, '%.4f %d\n', cueend, 1);
        fclose(fidcue);
        end 
        
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
    
        xpic = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
        ypic = randi(floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)]));
 
        randloc = [randloc; CenterRectOnPoint(halfpic, xpic, ypic)];
    
            %for i = 1; %probably won't work 
                %xypicsid = fopen(xypicsfn, 'a');
                %xloc = xpic;
                %yloc = ypic;
                %fprintf(xypicsid,'%.4f %d\n', xloc, yloc);
                %fclose(xypicsid);
           % end
    
                  
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
    picname=picfiles{min(i, length(picfiles))};
    img = imread(picname, 'png'); 
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


