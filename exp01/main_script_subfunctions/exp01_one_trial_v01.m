function [rec] = exp01_one_trial_v01(cfg, nTrial)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 15/01/2020


nottest = 1;

while nottest
    
    %% show one flip of stimuli
    % =======================================================================
    
    rec.flip_counter = 1;
    exp01_one_show_v01(cfg, nTrial);
    
    
    %% ask if repeat or continue to test
    % =======================================================================
    
    DrawFormattedText(cfg.ptb.PTBwindow, 'Test or not?', 'center','center', cfg.ptb.white);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    [secs, keyCode] = KbStrokeWait(0, GetSecs + cfg.exp.time.test_rewatch);
    
    if keyCode(cfg.key.y)
        nottest = 0;
    elseif keyCode(cfg.key.n)
        nottest = 1;
        rec.flip_counter = rec.flip_counter + 1;
    else
        nottest = 1;
    end
    
end

Screen('TextSize', cfg.ptb.PTBwindow, cfg.ptb.text.size);
DrawFormattedText(cfg.ptb.PTBwindow, 'Test or not?', 'center','center', cfg.ptb.white);

Screen('Flip', cfg.ptb.PTBwindow);



end