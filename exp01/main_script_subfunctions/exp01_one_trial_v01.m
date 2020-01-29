function [rec] = exp01_one_trial_v01(cfg, nTrial)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 15/01/2020


nottest = 1;

rec.flip_counter = 1; % initialise flip number

%% ask initial confidence before seeing stimuli
% =======================================================================

rec.conf = exp01_conf_v01(cfg, 'flip');

while nottest
    
    %% show one flip of stimuli
    % =======================================================================
    
    exp01_one_show_v01(cfg, nTrial);
    
    
    %% ask if repeat or continue to test
    % =======================================================================
    
    DrawFormattedText(cfg.ptb.PTBwindow, cfg.ptb.instructions.test_rewatch, 'center','center', cfg.ptb.white);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    
    % wait for key press for rewatch or not (yes is rewatch)
    [secs, keyCode] = KbStrokeWait(0, GetSecs + cfg.exp.time.test_rewatch);
    
    if keyCode(cfg.key.y)
        nottest = 1;
        rec.flip_counter = rec.flip_counter + 1; % increment the flip counter by 1
    elseif keyCode(cfg.key.n)
        nottest = 0;
    else
        nottest = 0;
    end
    
end



end