% 'Final 2.0' VidPlayback.m

abortit = 0;

% Playbackrate defaults to 1:
rate=1;

% Load first movie. This is a synchronous (blocking) load:
iteration = 1;
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
    
    
    i=0;
  
    % Get moviename of next file (after the one that is currently playing):
    
    iteration=iteration + 1;
    moviename=moviefiles{min(iteration, length(moviefiles))};
    t1 = GetSecs;

    
    % Playback loop: Fetch video frames and display them...
    while 1
        i=i+1;
        if abs(rate) > 0
           
            [tex pts] = Screen('GetMovieImage', window, movie, 1);
            
            % Valid texture returned?
            if tex < 0
                
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
        
        
        if prefetched==0 && pts > 0
           
            Screen('OpenMovie', window, moviename, 2, movie);
            prefetched=1;
        end
        
        
           if prefetched==1 && pts < lastpts
            
            prefetched = 0;
            lastpts = -1;
            break
        end
        
        % Keep track of playback time:
        lastpts = pts;
    end
    
    
    
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