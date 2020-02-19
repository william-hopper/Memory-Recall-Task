function [training] = exp01_one_training_v01(cfg, nTrain, train_or_main)
%
% This function includes one full training block of the experiment
%
% Author:   William Hopper
% Original: 05/02/2020

training.start_time = GetSecs;  % when did the show start
training.scriptname = mfilename('fullpath');  % save the name of this script

% flip to clear the buffer
Screen('Flip', cfg.ptb.PTBwindow);

% training or main experiment?
switch train_or_main
    case 'training'
        training.type = 'training';
    case 'main'
        training.type = 'main';
end

%% Display Trial Number
% =======================================================================

train_num = num2str(nTrain);
flip_num = num2str(cfg.exp.train.flips(nTrain));

DrawFormattedText(cfg.ptb.PTBwindow, [cfg.ptb.instructions.train_num train_num],...
    'center','center', cfg.ptb.white, [], [] ,[], cfg.ptb.text.vSpacing);

DrawFormattedText(cfg.ptb.PTBwindow, [cfg.ptb.instructions.train_flip_num flip_num],...
    'center',cfg.ptb.screenYpixels*0.6, cfg.ptb.white, [], [] ,[], cfg.ptb.text.vSpacing);

Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(cfg.exp.time.trial_num*2);

%% ask initial confidence before seeing stimuli
% =======================================================================

training.conf.conf_pre_flip = exp01_conf_v01(cfg, 'training1');

%% flip the stimuli
% =======================================================================
training.show.flip_counter = 1; % initialise flip number

for nFlip = 1:cfg.exp.train.flips(nTrain)
    
    
    exp01_one_flip_v01(cfg, nTrain, training);
    
    
    %% explain the repeat question
    
    wrap = ceil(length(cfg.ptb.instructions.test_rewatch_training)/6);
    DrawFormattedText(cfg.ptb.PTBwindow, cfg.ptb.instructions.test_rewatch_training, 'center','center', cfg.ptb.white, wrap, [] ,[], cfg.ptb.text.vSpacing);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    
    KbStrokeWait();
    training.show.flip_counter = training.show.flip_counter + 1; % increment the flip counter by 1
    
    
end

%% ask confidence before being tested
% =======================================================================

training.conf.conf_post_flip = exp01_conf_v01(cfg, 'training2');


%% testing
% =======================================================================

wrap = ceil(length(cfg.ptb.instructions.test_training)/4);
DrawFormattedText(cfg.ptb.PTBwindow, cfg.ptb.instructions.test_training, 'center','center', cfg.ptb.white, wrap, [],[], cfg.ptb.text.vSpacing);

Screen('Flip', cfg.ptb.PTBwindow);

KbStrokeWait();

training.test = exp01_test_v01(cfg, nTrain, training);

%% Display feedback
% =======================================================================

exp01_display_feedback_v01(cfg, training, nTrain);


%% moving on the the main experiment

end
