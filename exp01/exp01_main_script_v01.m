%% Memory Association Recall Task
% First experiment of PhD
% How do people update their Self-Efficacy function?

% Composed of:

% Scripts required:
% make sure to specify path directory

% Author: William Hopper 08/01/2020

%% Clearing
% =========================================================================
clear all; close all; clc; rng('default'); clear mex;


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


cfg.exp.n_trials                   = 3;                % number of trials
cfg.exp.baseline_reimbursement     = 15;               % how much money we promise as a baseline
cfg.exp.n_stim                     = 16;               % how many individual stimuli
cfg.exp.n_pairs                    = cfg.exp.n_stim/2; % how many associations to learn

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
cfg.path.images                                = ([cfg.path.stim,'Images/']);
cfg.path.training                              = '.../.../.../ownCloud/PhD/Matlab/Memory-Recall-Task/raw';  %'raw/training/';  % path to save raw exp data
cfg.path.main_exp                              = '.../.../.../ownCloud/PhD/Matlab/Memory-Recall-Task/main_exp';  % 'raw/main_exp/';  % path to save main exp data

% create_missing_directories(cfg.path); % need to specify file location!


%% Generate permutations of pairs
% value refers to the image number from stimuli/images
% row 1 & 2 of column i are a pair
% =========================================================================

cfg.exp.pair_perms = generate_pair_perms_v01(cfg);

%% Generate permutations image locations
% 1:n_stim -> grid read left to right, top to bottom
% EXAMPLE WITH A 4x4 GRID:
% location_perms(1) = top left corner, locations_perms(16) = bottom right
% corner -- value of location_perms refers to which image i.e. if
% location_perms(4) = 8 then image 8 will be shown in the top right corner
% =========================================================================

cfg.exp.location_perms = generate_location_perms_v01(cfg);

%% Generate order of images tested
% as with pair_perms (:,1) is first pair, (:,2) is second pair etc...
% function shuffles pairs for testing
% =========================================================================

cfg.exp.test_perms = generate_test_perms_v01(cfg);

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


%% initialise keyboard
% =========================================================================

KbName('UnifyKeyNames');
cfg.key.space  = KbName('space');
cfg.key.escape = KbName('ESCAPE');
cfg.key.enter = KbName('Return');
cfg.key.left = KbName('LeftArrow');
cfg.key.right = KbName('RightArrow');
cfg.key.y = KbName('y');
cfg.key.n = KbName('n');
cfg.key.o = KbName('o');


%%  Set up psychtoolbox, open screen etc., save to cfg structure
% =======================================================================
% Initial parameters
PsychDefaultSetup(2);

if cfg.do.debug
    PsychDebugWindowConfiguration(1);  % added for the testing phase
end

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);  % supress start screen
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

% pre-allocate coord/grid array (an array for each difficulty level
% cfg.ptb.coord = zeros(2, cfg.exp.n_stim, 2);
% cfg.ptb.grid = zeros(4, cfg.exp.n_stim, 2);

cfg.ptb.grid_dim(1) = 1.5; % 4 squares
cfg.ptb.grid_dim(2) = 2.5; % 6 squares

% Coordinates of stimuli
cfg.exp.numStim = round(sqrt(cfg.exp.n_stim));

% easy (4x4)
[x, y] = meshgrid(-cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1), -cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1));
cfg.ptb.pixelScale = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels) / (cfg.ptb.grid_dim(1) * 2 + 2);
x = x .* cfg.ptb.pixelScale;
y = y .* cfg.ptb.pixelScale;
cfg.ptb.coord = [reshape(x', 1, cfg.exp.n_stim)+cfg.ptb.xCentre; reshape(y', 1, cfg.exp.n_stim)+cfg.ptb.yCentre]; % coordinates of rectangle centre
cfg.ptb.grid = [cfg.ptb.coord(1,:)-round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)-round(cfg.ptb.pixelScale/2);...
    cfg.ptb.coord(1,:)+round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)+round(cfg.ptb.pixelScale/2)]; % pixel location of grid
cfg.stim.mask.base_rect = [0 0 cfg.ptb.pixelScale cfg.ptb.pixelScale] * 0.9;

% % hard (6x4)
% [x, y] = meshgrid(-cfg.ptb.grid_dim(2):1:cfg.ptb.grid_dim(2), -cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1));
% cfg.ptb.pixelScale = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels) / (cfg.ptb.grid_dim(1) * 2 + 2);
% x = x .* cfg.ptb.pixelScale;
% y = y .* cfg.ptb.pixelScale;
% cfg.ptb.coord = [reshape(x', 1, cfg.exp.n_stim)+cfg.ptb.xCentre; reshape(y', 1, cfg.exp.n_stim)+cfg.ptb.yCentre]; % coordinates of rectangle centre
% cfg.ptb.grid = [cfg.ptb.coord(1,:)-round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)-round(cfg.ptb.pixelScale/2);...
%     cfg.ptb.coord(1,:)+round(cfg.ptb.pixelScale/2);cfg.ptb.coord(2,:)+round(cfg.ptb.pixelScale/2)]; % pixel location of grid
% cfg.stim.mask.base_rect = [0 0 cfg.ptb.pixelScale cfg.ptb.pixelScale] * 0.9;


    % Load Images
    % Check to make sure that folder actually exists.  Warn user if it doesn't.
    if ~isdir(cfg.path.images)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', cfg.path.images);
        uiwait(warndlg(errorMessage));
        return;
    end
    
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(cfg.path.images, '*.jfif'); % Change to whatever pattern you need.
    cfg.stim.theImages = dir(filePattern);
    for k = 1:cfg.exp.n_stim
        
        baseFileName = cfg.stim.theImages(k).name;
        fullFileName = fullfile(cfg.path.images, baseFileName);
        cfg.stim.theImages(k).array = imread(fullFileName); % read the file
        
        % for each image generate an image texture and scale it appropriately
        % for the grid
        cfg.stim.theImages(k).org_size = size(cfg.stim.theImages(k).array); % original size of image
        cfg.stim.theImages(k).asp_rat =  min(cfg.stim.theImages(k).org_size(1:2))/max(cfg.stim.theImages(k).org_size(1:2));
        cfg.stim.theImages(k).adj_size(2) = cfg.ptb.pixelScale*0.9; % scale the image (height)
        cfg.stim.theImages(k).adj_size(1) = cfg.stim.theImages(k).adj_size(2)*cfg.stim.theImages(k).asp_rat; % scale the image (width)
        cfg.stim.theImages(k).texture = Screen('MakeTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(k).array); % generate image textures
        
        % rescale image to grid
        cfg.stim.theImages(k).img_rect = [0 0 cfg.stim.theImages(k).adj_size(1) cfg.stim.theImages(k).adj_size(1)];
        
        % generate an image rectangle for each grid location
        for nGrid = 1:cfg.exp.n_stim
            
            cfg.stim.theImages(k).scaled_rect(nGrid,:) = CenterRectOnPointd(cfg.stim.theImages(k).img_rect, cfg.ptb.coord(1,nGrid), cfg.ptb.coord(2,nGrid));
            
        end
        
        % create mask rectangles
        cfg.stim.mask.rect(:,k) = CenterRectOnPointd(cfg.stim.mask.base_rect, cfg.ptb.coord(1,k), cfg.ptb.coord(2,k));
        
        
    end
    % Instructions parameters
    load([cfg.path.stim 'text.mat'], 'text');
    cfg.ptb.instructions = text;
    
    % Text parameters
    cfg.ptb.text.size                      = 30; % what should be the size of texts
    cfg.ptb.text.position                  = cfg.ptb.screenYpixels * 0.20; % Set text position
    cfg.ptb.text.Col                       = cfg.ptb.black;
    cfg.ptb.text.Colbis                    = cfg.ptb.white;
    cfg.ptb.text.gray                      = [180 180 180]; % gray
    cfg.ptb.text.ColAlternative            = [50 50 200]; % blue
    cfg.ptb.text.bigFont                   = 25;
    
    Screen('TextSize', cfg.ptb.PTBwindow, cfg.ptb.text.size);
    
    
    % Pre-flip confidence response parameters
    cfg.ptb.conf.text_colour = [1 1 1];
    cfg.ptb.conf.numchoices = 8;
    cfg.ptb.conf.label = ['0' '5' '8'];
    cfg.ptb.conf.confirmcolor = [255 255 0];
    cfg.ptb.conf.numcolors = [255 255 255];
    
    
    
    
    %% Main Experiment
    % =========================================================================
    
    if cfg.do.main_experiment
        
        rec = cell(1, cfg.exp.n_trials);
        
        for nTrial = 1:cfg.exp.n_trials
            
            rec{1, nTrial} = exp01_one_trial_v01(cfg, nTrial);
            
        end
    end
    
    sca; % close screen