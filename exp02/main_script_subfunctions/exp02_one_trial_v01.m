function [trial] = exp02_one_trial_v01(cfg, nTrial, train_or_main)
%
% This function includes one full trial of the experiment
%
% Author:   William Hopper
% Original: 06/02/2020


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

exp02_one_flip_v01(cfg, nTrial, trial);


%% Test
% =======================================================================

trial.test = exp02_test_v01(cfg, nTrial, trial);

%% Confidence Judgement
% ========================================================================

% rect = [0 cfg.ptb.screenYpixels*0.8 cfg.ptb.screenXpixels cfg.ptb.screenYpixels];

trial.conf = exp02_conf_v01(cfg);




end