function [trial] = exp01_one_trial_v01(cfg, nTrial, train_or_main)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 15/01/2020



trial.start_time = GetSecs;  % when did the show start
trial.scriptname = mfilename('fullpath');  % save the name of this script


% flip to clear the buffer
Screen('Flip', cfg.ptb.PTBwindow);

% training or main experiment?
switch train_or_main
    case 'training'
        trial.type = 'training';
    case 'main'
        trial.type = 'main';
end

%% Display Trial Number
% =======================================================================

trial_num = num2str(nTrial);

DrawFormattedText(cfg.ptb.PTBwindow, [cfg.ptb.instructions.trial_num trial_num],...
    'center','center', cfg.ptb.white);

Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(cfg.exp.time.trial_num);

%% show one flip of stimuli
% =======================================================================

trial.show.flip_counter = 1; % initialise flip number

exp01_one_flip_v01(cfg, nTrial, trial);



%% ask initial confidence after seeing once
% =======================================================================

trial.conf.conf_SE(1,:) = exp01_conf_v01(cfg, 'flip');
trial.conf.conf_SE(2,:) = exp01_conf_v01(cfg, 'SE');

%% show one flip of stimuli
% =======================================================================

nottest = 1;
while nottest
    
    
    exp01_one_flip_v01(cfg, nTrial, trial);
    
    
    %% ask if repeat or continue to test
    % =======================================================================
    wrap = ceil(length(cfg.ptb.instructions.test_rewatch)/cfg.ptb.text.n_lines);
    DrawFormattedText(cfg.ptb.PTBwindow, cfg.ptb.instructions.test_rewatch, 'center','center', cfg.ptb.white, wrap);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    
    % wait for key press for rewatch or not (yes is rewatch)
    [~, keyCode] = KbStrokeWait(0, GetSecs + cfg.exp.time.test_rewatch);
    
    if any(keyCode)
        nottest = 1;
        trial.show.flip_counter = trial.show.flip_counter + 1; % increment the flip counter by 1
    else
        nottest = 0;
    end
    
end


%% ask confidence before being tested
% =======================================================================

trial.conf.conf_pre_test = exp01_conf_v01(cfg, 'test');

%% testing
% =======================================================================


trial.test = exp01_test_v01(cfg, nTrial, trial);


%% Display feedback
% =======================================================================

exp01_display_feedback_v01(cfg, trial, nTrial);


end