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

fn = 'PHOTO.xlsx';
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
stim5 = data.stim5;
stim6 = data.stim6;

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

%% Display Pics
escapenumber = KbName('escape');
for blocknumber = 1:8 %in the old script there were 24 blocks but now there are 12

    %Frame color
 
    col = eval(blocks{blocknumber,7}); %5 refers to the color column, should read out the value for green/blue
    
    %Picture File Names
    picfiles = blocks(blocknumber,1:6); %so this line basically says to  read rows 1-12 col 1-6 and calls them picfiles 
    
        
    
    for i=1:6
         Screen('FrameRect', window, col, wsize, framew); %can switch w/ below 
    
    picname=picfiles{min(i, length(picfiles))};
    img = imread(picname, 'png'); %when I check the script it does name an image file so not sure why its not popping up.
   
    %Set cue trial
        if i == 1      
        Screen('FrameRect', window, col, wsize, framew);
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



        
        %set jitter time for cue
           cuetime = 1.5;
        
        %write cue start times to text file
              
                %fidcue = fopen(cuefn, 'a'); %has a problem with this line b/c cuefn is defined in main_v2
                stcue_system = GetSecs;
                stcue = stcue_system - exp_st;
                %fprintf(fidcue, '%.4f\t', stcue - exp_st);
                %fclose(fidcue);
       
        
            Screen('Flip', window); %also has a problem here
            WaitSecs(cuetime);
        
                 %write cue duration to text file

                %fidcue = fopen(cuefn, 'a');
                cuedur = GetSecs - stcue_system;
                %fprintf(fidcue, '%.4f %d\n', 'cueend');
                %fprintf(fidcue, '%.4f %d\n', cueend);
                %fclose(fidcue);
                stblock = GetSecs;
                start = stblock - exp_st; 
              
        
        end
        
             
         photost = GetSecs;
         xpic(i) = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
         ypic(i) = randi([floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)])]); 
        randloc = CenterRectOnPoint(halfpic, xpic(i), ypic(i));
    
            %write a file on the x and y coordinates 
                xylocid = fopen(xylocfn, 'a');
                xloc = xpic(i);
                yloc = ypic(i);
                fprintf(xylocid,'x %.4f y %.4f\n', xloc, yloc);
                fclose(xylocid);

    
                  
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
            
            
    
    Screen('FrameRect', window, col, wsize, framew);
    Screen('PutImage', window, img, randloc);
    Screen('Flip', window);
    WaitSecs(2.68);
    
    photoend = GetSecs;
    phototime = photoend - photost;
    fidvtime = fopen(vtimefn, 'a');
    fprintf(fidvtime, 'photo time %.4f\n', phototime);
    fclose(fidvtime);
    end


blockdur = GetSecs - stblock;
blocktot = blockdur + cuedur;
fidblock = fopen(blockfn, 'a');
fprintf(fidblock, 'bstart %.4f btot %.4f cuedur %.4f bdur %.4f\n', ...
    start, blocktot, cuedur, blockdur);
fclose(fidblock);


% End of playback - clear last picture:
Screen('Flip', window);

  %Wait 10 seconds
    then = GetSecs;
    wait = 0;
    while wait < 12
        [HitKey secs KeyCode] = KbCheck;
        if find(KeyCode) == escapenumber,
            ListenChar(0);
            sca;
        end
        wait = GetSecs-then; 
    end  
end

ListenChar(0);


