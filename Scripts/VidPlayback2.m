%% 'Final 2.0' VidPlayback.m

abortit = 0;

% Playbackrate defaults to 1:
rate=1;

% Load first movie. This is a synchronous (blocking) load:
iteration = 1;
%moviename = [pwd filesep 'Tweezers_Pinch.mp4']
moviename=moviefiles{min(iteration, length(moviefiles))};

[movie, movieduration, fps, imgw, imgh] = Screen('OpenMovie', window, moviename);

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
            Screen('FrameRect', window, col, wsize, framew);
            
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
                Screen('FrameRect', window, col, wsize, framew);
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
    fidvtime = fopen(vtimefn, 'a');
    fprintf(fidvtime, '%.4f\n', telapsed);
    fclose(fidvtime); 
    
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