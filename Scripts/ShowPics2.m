%% 'Final 2.0' ShowPics.m
%blocks(1,1:4) is first row of photos
% Load pictures into variable and display for 3 seconds

randloc = [];
for i=1:4
    Screen('FrameRect', window, col, wsize, framew); %can switch w/ below 
    
    picname=picfiles{min(i, length(picfiles))};
    img = imread(picname, 'png'); %when I check the script it does name an image file so not sure why its not popping up.
   
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
    
            for i = 1; %probably won't work 
                xypicsid = fopen(xypicsfn, 'a');
                xloc = xpic;
                yloc = ypic;
                fprintf(xypicsid,'%.4f %d\n', xloc, yloc);
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

