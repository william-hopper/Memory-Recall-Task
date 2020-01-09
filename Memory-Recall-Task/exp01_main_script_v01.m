%% Memory Association Recall Task
% First experiment of PhD
% How do people update their Self-Efficacy function?

% Composed of:

% Scripts required:

% Author: William Hopper 08/01/2020

%% Clearing
% =========================================================================
clear all; close all; clc; rng('shuffle'); clear mex;


%% What to do
% =========================================================================

cfg.do.debug                       = 0;         % should we run in debug mode?

cfg.do.instructions                = 1;         % do we want instructions?
cfg.do.training                    = 1;         % should we play training

cfg.do.main_experiment             = 1;         % should we play main_experiment
cfg.do.reimbursement               = 1;         % should we play reimbursement


%% set configuration parameters of experiment
% =========================================================================
cfg.exp.name                       = 'exp_01';  % name of the experiment

if cfg.do.debug
else
end


cfg.exp.n_trials                   = 30;        % number of trials
cfg.exp.baseline_reimbursement     = 15;        % how much money we promise as a baseline

cfg.exp.time.flip_speed            = 0.5;       % number of seconds between flips
cfg.exp.time.response_speed        = 2;         % number of seconds for participant response
cfg.exp.time.cnf_time              = 5;         % number of seconds for confidence response

cfg.exp.time.show_ready            = 2;         % how long should ready be shown at the beginning of each trial?
cfg.exp.time.test_rewatch          = 5;         % how long do participants have to decide to rewatch stimuli?
cfg.exp.time.show_feedback         = 5;         % how long should the feedback be shown at end of the trial?


%% set paths
% =========================================================================
addpath(genpath(pwd));  % add all the sub functions

cfg.path.stim                                  = 'Stimuli/'; % link to Stimuli folder
cfg.path.instructions                          = ([cfg.path.stim,'Instructions/Image_instructions/']);
cfg.path.training                              = '.../.../.../ownCloud/PhD/Matlab/Memory-Recall-Task/raw';  %'raw/training/';  % path to save raw exp data
cfg.path.main_exp                              = '.../.../.../ownCloud/PhD/Matlab/Memory-Recall-Task/main_exp';  % 'raw/main_exp/';  % path to save main exp data

create_missing_directories(cfg.path);


%% Ask for subject id
% =========================================================================

cfg.subname         = input('Subject initials: ','s'); % ask for intials
cfg.subid           = input('Subject number: ');  % ask for number

% hostname and filename
cfg.scriptname      = mfilename('fullpath');  % save the name of this script
[~, cfg.hostname]   = system('hostname'); % get the name of the PC
cfg.hostname        = deblank(cfg.hostname);  % remove wired characters

cfg.start_time      = datestr(now, 30); % start time
cfg.fname           = sprintf('%02i_%s_%s', cfg.subid, cfg.subname, cfg.start_time);



