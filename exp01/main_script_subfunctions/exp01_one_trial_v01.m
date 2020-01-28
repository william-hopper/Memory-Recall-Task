function [rec] = exp01_one_trial_v01(cfg)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 15/01/2020


nottest = 1;

while nottest
    
    %% show one flip of stimuli
    % =======================================================================
    
    for nTrial = 1:cfg.exp.n_trials
        flip_counter = 1;
        exp01_one_show_v01(cfg, nTrial);
    end
    
    %% ask if repeat or continue to test
    % =======================================================================
    
    DrawFormattedText(cfg.ptb.PTBwindow, 'Test or not?', 'center','center', [0 0 0]);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    [secs, keyCode] = KbStrokeWait;
    if keyCode(cfg.key.y)
        nottest = 0;
    elseif keyCode(cfg.key.n)
        nottest = 1;
        flip_counter = flip_counter + 1;
    end
    
end

DrawFormattedText(cfg.ptb.PTBwindow, 'Test or not?', 'center','center', [0 0 0]);

Screen('Flip', cfg.ptb.PTBwindow);



end