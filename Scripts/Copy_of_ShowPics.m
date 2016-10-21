%% 'Final 2.0' ShowPics.m

% Load pictures into variable and display for 3 seconds
for i=1:4
    %Screen('FrameRect', window, col, wsize, framew);
    picname=picfiles{min(i, length(picfiles))};
    img = imread(picname, 'png');
    %Set cue trial
    if i == 1      
        Screen('FrameRect', window, col, wsize, framew);
        if strcmp((blocks(blockno,5)), 'point')
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
        fidcue = fopen(cuefn, 'a');
        stcue = GetSecs;
        fprintf(fidcue, '%.4f\t', stcue - exp_st);
        fclose(fidcue);
        
        Screen('Flip', window);
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
    
    xpic = randi([buffer+(halfpic(3)/2), (wsize(3)-(halfpic(3)/2)-buffer)]);
    ypic = randi(floor([buffer+(halfpic(4)/2), (wsize(4)-(halfpic(4)/2)-buffer)]));
 
    randloc = CenterRectOnPoint(halfpic, xpic, ypic);
    
    
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
fprintf(fidblock, '%.4f %d\n', blockend, 1);
fclose(fidblock);

% End of playback - clear last picture:
Screen('Flip', window);

