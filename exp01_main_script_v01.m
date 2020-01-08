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

cfg.do.debug                                   = 0; % should we run in debug mode?

cfg.do.instructions                            = 1; % do we want instructions?
cfg.do.training_with_feedback                  = 1; % should we play training with feedback

cfg.do.main_experiment                         = 1; % should we play main_experiment
cfg.do.reimbursement                           = 1; % should we play reimbursement