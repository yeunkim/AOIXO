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
fnpath = 'C:/Users/Squak/Desktop/Dropbox/AOIXI/Videos';

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

%% Display Pics
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



