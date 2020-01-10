%% Memory Association Recall Task
% First experiment of PhD
% How do people update their Self-Efficacy function?

% Composed of:

% Scripts required:
% make sure to specify path directory

% Author: William Hopper 08/01/2020

%% Clearing
% =========================================================================
clear all; close all; clc; rng('shuffle'); clear mex;


%% What to do
% =========================================================================

cfg.do.debug                       = 1;         % should we run in debug mode?

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
cfg.exp.nStim                      = 16;        % how many individual stimuli 

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

% create_missing_directories(cfg.path); % need to specify file location!


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



%%  Set up psychtoolbox, open screen etc., save to cfg structure
% =======================================================================
% Initial parameters
PsychDefaultSetup(2);

if cfg.do.debug
    PsychDebugWindowConfiguration;  % added for the testing phase
end

Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference','VisualDebugLevel', 0);  % supress start screen
% HideCursor;

cfg.ptb.screens = Screen('Screens'); % open screen
cfg.ptb.screenNumber = max(cfg.ptb.screens); % counter the number of max screens
cfg.ptb.white = WhiteIndex(cfg.ptb.screenNumber); % set up white
cfg.ptb.black = BlackIndex(cfg.ptb.screenNumber); % set up black
[cfg.ptb.PTBwindow, cfg.ptb.PTBwindowRect] = PsychImaging('Openwindow', cfg.ptb.screenNumber, cfg.ptb.black);
Screen('BlendFunction', cfg.ptb.PTBwindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set the blend funciton for the screen

[cfg.ptb.xCentre, cfg.ptb.yCentre] = RectCenter(cfg.ptb.PTBwindowRect); % Get the centre coordinate of the window
[cfg.ptb.screenXpixels, cfg.ptb.screenYpixels] = Screen('WindowSize', cfg.ptb.PTBwindow); % Get the center coordinate of the window in pixels
cfg.ptb.ifi = Screen('GetFlipInterval', cfg.ptb.PTBwindow); % Query the frame duration
cfg.ptb.framerate = Screen('FrameRate', cfg.ptb.PTBwindow); % Sync us and get a time stamp
cfg.ptb.waitframes = 1; % set up waitframes

% Position parameters
cfg.ptb.yHigh                          = cfg.ptb.yCentre/2 ;
cfg.ptb.yBottom                        = 9/5*cfg.ptb.yCentre;

% Coordinates of stimuli
cfg.exp.numStim = round(sqrt(cfg.exp.nStim));
[x, y] = meshgrid((1:cfg.exp.numStim)-cfg.exp.numStim+cfg.exp.numStim/4, (1:cfg.exp.numStim)-cfg.exp.numStim/1.8);
[x, y] = meshgrid(-2:1:2, -2:1:2);
cfg.ptb.pixelScale = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels)/(cfg.exp.numStim);
x = x .* cfg.ptb.pixelScale;
y = y .* cfg.ptb.pixelScale;
cfg.ptb.coord = [reshape(x, 1, cfg.exp.nStim)+cfg.ptb.xCentre; reshape(y, 1, cfg.exp.nStim)+cfg.ptb.yCentre];
% COORD = COORD(:,randperm(size(COORD, 2)));
cfg.ptb.grid = [cfg.ptb.coord(1,:)-round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)-round(cfg.ptb.pixelScale/2);...
                    cfg.ptb.coord(1,:)+round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)+round(cfg.ptb.pixelScale/2)];

% Instructions parameters
load([cfg.path.stim 'text.mat'], 'text');
cfg.ptb.instructions = text;

% Text parameters
cfg.ptb.text.size                      = 60; % what should be the size of texts
cfg.ptb.text.position                  = cfg.ptb.screenYpixels * 0.20; % Set text position
cfg.ptb.text.Col                       = cfg.ptb.black;
cfg.ptb.text.Colbis                    = cfg.ptb.white;
cfg.ptb.text.gray                      = [180 180 180]; % gray
cfg.ptb.text.ColAlternative            = [50 50 200]; % blue
cfg.ptb.text.bigFont                   = 25;

exp01_one_show_v01(cfg)

