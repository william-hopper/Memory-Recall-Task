function [rec] = exp01_display_feedback_v01(cfg, trial, nTrial)
%
% This function displays the feedback following a test
% The participant is shown which pairs they got correct/incorrect
%
% Author:   William Hopper
% Original: 03/02/2020

switch trial.type
    case 'training'
        location_perms = cfg.exp.train.location_perms;
        pair_perms     = cfg.exp.train.pair_perms;
        test_perms     = cfg.exp.train.test_perms;
    case 'main'
        location_perms = cfg.exp.location_perms;
        pair_perms     = cfg.exp.pair_perms;
        test_perms     = cfg.exp.test_perms;
end

% display score out of n_pairs
trial_score = num2str(sum(trial.test.response(:,2)));

feedback_st = sprintf('%s', [trial_score '/8']);
DrawFormattedText(cfg.ptb.PTBwindow,feedback_st, cfg.ptb.screenXpixels*0.8, 'center', [1 1 1]);

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

% mask the whole grid
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);

% flip
Screen('Flip', cfg.ptb.PTBwindow, 0, 1);

correct = repelem(trial.test.response(:,2),2,1);

% display images
for k = 1:cfg.exp.n_stim
    
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(k).texture, [],...
        cfg.stim.theImages(k).scaled_rect(location_perms(nTrial,:) == k,:), 0);
    
    flip = ~mod(k,2);
    
    if correct(k) % if correct green else red
        grid_colour = [0 255 0];
    else
        grid_colour = [255 0 0];
    end
    
    Screen('FrameRect', cfg.ptb.PTBwindow, grid_colour, cfg.ptb.grid(:,location_perms(nTrial,:) == k), 10)
    
    if flip % flip to screen every pair and don't clear the buffer
        Screen('Flip', cfg.ptb.PTBwindow, 0, 1);
        WaitSecs(cfg.exp.time.flip_speed);
    end
    

    
    
end

WaitSecs(cfg.exp.time.show_feedback);

end