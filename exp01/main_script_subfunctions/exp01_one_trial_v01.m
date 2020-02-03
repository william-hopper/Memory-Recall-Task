function [trial] = exp01_one_trial_v01(cfg, nTrial)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 15/01/2020


trial.start_time = GetSecs;  % when did the show start
trial.scriptname = mfilename('fullpath');  % save the name of this script

trial.show.flip_counter = 1; % initialise flip number

%% ask initial confidence before seeing stimuli
% =======================================================================

trial.conf.conf_pre_flip = exp01_conf_v01(cfg, 'flip');

nottest = 1;
while nottest
    
    %% show one flip of stimuli
    % =======================================================================
    
    exp01_one_flip_v01(cfg, nTrial);
    
    
    %% ask if repeat or continue to test
    % =======================================================================
    
    DrawFormattedText(cfg.ptb.PTBwindow, cfg.ptb.instructions.test_rewatch, 'center','center', cfg.ptb.white);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    
    % wait for key press for rewatch or not (yes is rewatch)
    [secs, keyCode] = KbStrokeWait(0, GetSecs + cfg.exp.time.test_rewatch);
    
    if keyCode(cfg.key.y)
        nottest = 1;
        trial.flip_counter = trial.show.flip_counter + 1; % increment the flip counter by 1
    elseif keyCode(cfg.key.n)
        nottest = 0;
    else
        nottest = 0;
    end
    
end


%% ask confidence before being tested
% =======================================================================

trial.conf.conf_pre_test = exp01_conf_v01(cfg, 'test');

%% testing
% =======================================================================


trial.test = exp01_test_v01(cfg, nTrial);


%% Display feedback
% =======================================================================
trial_score = num2str(sum(trial.test.response(:,2)));

feedback_st = sprintf('%s', [trial_score '/8']);
DrawFormattedText(cfg.ptb.PTBwindow,feedback_st, 'center', 'center', [1 1 1]);

Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(3);
end