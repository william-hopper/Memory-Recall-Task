%% Memory Association Recall Task
% Experiment 2
% Can we get a reliable measure of confidence with reaction time?
% Present one flip of grid and then test on one random pair. After asking
% confidence, show feedback.
%
% Composed of:
%
% Scripts required
% make sure to specify path directory

% Author: William Hopper 06/02/2020

%% Clearing
% =========================================================================
clear all; close all; clc; rng('Shuffle'); clear mex;


%% What to do
% =========================================================================

cfg.do.debug                       = 0;         % should we run in debug mode?
cfg.do.cheat                       = 0;         % do we want to cheat?

cfg.do.instructions                = 0;         % do we want instructions?
cfg.do.training                    = 0;         % should we play training

cfg.do.main_experiment             = 1;         % should we play main_experiment
cfg.do.reimbursement               = 1;         % should we play reimbursement

%% set configuration parameters of experiment
% =========================================================================
cfg.exp.name                       = 'exp_02';  % name of the experiment

if cfg.do.debug
else
end

cfg.exp.random = 0;
cfg.exp.baseline_reimbursement     = 15;               % how much money we promise as a baseline

cfg.exp.n_stim                     = [16];          % how many individual stimuli

for i = 1:length(cfg.exp.n_stim)
    cfg.exp.n_pairs(i)             = cfg.exp.n_stim(i)/2; % how many associations to learn
end
        
cfg.exp.n_trials                   = 48;               % number of trials (must be a multiple of n_pairs)
cfg.exp.train.trials               = 4;                % number of training trials

cfg.exp.time.flip_speed            = 0.75;             % number of seconds between flips
cfg.exp.time.response_speed        = 1;                % number of seconds before test stimuli presented
cfg.exp.time.cnf_time              = 5;                % number of seconds for confidence response
cfg.exp.time.highlight             = 0.5;                % number of seconds response highlighted
cfg.exp.time.trial_num             = 1.5;              % how long should ready be shown at the beginning of each trial?
cfg.exp.time.show_feedback         = 3;                % how long should the feedback be shown at end of the trial?


%% set paths
% =========================================================================
addpath(genpath(pwd));  % add all the sub functions

cfg.path.stim                     = 'Stimuli/'; % link to Stimuli folder
cfg.path.instructions             = ([cfg.path.stim,'Instructions/Image_instructions/']);
cfg.path.images                   = ([cfg.path.stim,'Images/']);
cfg.path.training                 = ['C:/Users/' getenv('username') '/ownCloud/PhD/Matlab/Memory-Recall-Task/exp02/raw/training/'];  %'raw/training/';  % path to save raw exp data
cfg.path.main_exp                 = ['C:/Users/' getenv('username') '/ownCloud/PhD/Matlab/Memory-Recall-Task/exp02/raw/main/'];  % 'raw/main_exp/';  % path to save main exp data


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
HideCursor;

cfg.ptb.screens = Screen('Screens'); % open screen
cfg.ptb.screenNumber = max(cfg.ptb.screens); % counter the number of max screens
cfg.ptb.white = WhiteIndex(cfg.ptb.screenNumber); % set up white
cfg.ptb.black = BlackIndex(cfg.ptb.screenNumber); % set up black
[cfg.ptb.PTBwindow, cfg.ptb.PTBwindowRect] = PsychImaging('Openwindow', cfg.ptb.screenNumber, cfg.ptb.black);
Screen('BlendFunction', cfg.ptb.PTBwindow, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set the blend funciton for the screen

[cfg.ptb.PTBoffwindow, cfg.ptb.PTBoffwindowRect] = Screen('OpenoffscreenWindow', cfg.ptb.screenNumber, cfg.ptb.black);

[cfg.ptb.xCentre, cfg.ptb.yCentre] = RectCenter(cfg.ptb.PTBwindowRect); % Get the centre coordinate of the window
[cfg.ptb.screenXpixels, cfg.ptb.screenYpixels] = Screen('WindowSize', cfg.ptb.PTBwindow); % Get the center coordinate of the window in pixels
cfg.ptb.ifi = Screen('GetFlipInterval', cfg.ptb.PTBwindow); % Query the frame duration
cfg.ptb.framerate = Screen('FrameRate', cfg.ptb.PTBwindow); % Sync us and get a time stamp
cfg.ptb.waitframes = 1; % set up waitframes

% Position parameters
cfg.ptb.yHigh                          = cfg.ptb.yCentre/2 ;
cfg.ptb.yBottom                        = 9/5*cfg.ptb.yCentre;

%% Grid coordinates
% =======================================================================

% pre-allocate coord/grid array (an array for each difficulty level
% cfg.ptb.coord = zeros(2, cfg.exp.n_stim, 2);
% cfg.ptb.grid = zeros(4, cfg.exp.n_stim, 2);

cfg.ptb.grid_dim(1) = 1.5; % 4 squares
cfg.ptb.grid_dim(2) = 2.5; % 6 squares
cfg.ptb.grid_dim(3) = 1;   % 3 squares

for i = 1:length(cfg.exp.n_stim)
    
    switch cfg.exp.n_stim
        case 12 % (4x3)
            
            [x, y] = meshgrid(-cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1), -cfg.ptb.grid_dim(3):1:cfg.ptb.grid_dim(3));
            cfg.ptb.pixelScale(i) = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels) / (cfg.ptb.grid_dim(1) * 2 + 2);
            x = x .* cfg.ptb.pixelScale(i);
            y = y .* cfg.ptb.pixelScale(i);
            coord = [reshape(x', 1, cfg.exp.n_stim(i))+cfg.ptb.xCentre; reshape(y', 1, cfg.exp.n_stim(i))+cfg.ptb.yCentre]; % coordinates of rectangle centre
            cfg.ptb.coords(i).grid = [coord(1,:)-round(cfg.ptb.pixelScale(i)/2);coord(2,:)-round(cfg.ptb.pixelScale(i)/2);...
                coord(1,:)+round(cfg.ptb.pixelScale(i)/2);coord(2,:)+round(cfg.ptb.pixelScale(i)/2)]; % pixel location of grid
            cfg.stim.mask.base_rect(i,:) = [0 0 cfg.ptb.pixelScale(i) cfg.ptb.pixelScale(i)] * 0.9;
            
            cfg.ptb.coords(i).coord = coord;
            
        case 16 % (4x4)
            
            [x, y] = meshgrid(-cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1), -cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1));
            cfg.ptb.pixelScale(i) = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels) / (cfg.ptb.grid_dim(1) * 2 + 2);
            x = x .* cfg.ptb.pixelScale(i);
            y = y .* cfg.ptb.pixelScale(i);
            coord = [reshape(x', 1, cfg.exp.n_stim(i))+cfg.ptb.xCentre; reshape(y', 1, cfg.exp.n_stim(i))+cfg.ptb.yCentre]; % coordinates of rectangle centre
            cfg.ptb.coords(i).grid = [coord(1,:)-round(cfg.ptb.pixelScale(i)/2);coord(2,:)-round(cfg.ptb.pixelScale(i)/2);...
                coord(1,:)+round(cfg.ptb.pixelScale(i)/2);coord(2,:)+round(cfg.ptb.pixelScale(i)/2)]; % pixel location of grid
            cfg.stim.mask.base_rect(i,:) = [0 0 cfg.ptb.pixelScale(i) cfg.ptb.pixelScale(i)] * 0.9;
            
            cfg.ptb.coords(i).coord = coord;
            
        case 24 % (6x4)
            
            [x, y] = meshgrid(-cfg.ptb.grid_dim(2):1:cfg.ptb.grid_dim(2), -cfg.ptb.grid_dim(1):1:cfg.ptb.grid_dim(1));
            cfg.ptb.pixelScale(i) = min(cfg.ptb.screenXpixels, cfg.ptb.screenYpixels) / (cfg.ptb.grid_dim(2) * 2 + 2);
            x = x .* cfg.ptb.pixelScale(i);
            y = y .* cfg.ptb.pixelScale(i);
            coord = [reshape(x', 1, cfg.exp.n_stim(i))+cfg.ptb.xCentre; reshape(y', 1, cfg.exp.n_stim(i))+cfg.ptb.yCentre]; % coordinates of rectangle centre
            cfg.ptb.coords(i).grid = [coord(1,:)-round(cfg.ptb.pixelScale(i)/2);coord(2,:)-round(cfg.ptb.pixelScale(i)/2);...
                coord(1,:)+round(cfg.ptb.pixelScale(i)/2);coord(2,:)+round(cfg.ptb.pixelScale(i)/2)]; % pixel location of grid
            cfg.stim.mask.base_rect(i,:) = [0 0 cfg.ptb.pixelScale(i) cfg.ptb.pixelScale(i)] * 0.9;
            
            cfg.ptb.coords(i).coord = coord;
            
    end
end

%% Load Images
% =======================================================================
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(cfg.path.images)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', cfg.path.images);
    uiwait(warndlg(errorMessage));
    return;
end

% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(cfg.path.images, '*.jfif'); % Change to whatever pattern you need.
cfg.stim.theImages = dir(filePattern);

for k = 1:max(cfg.exp.n_stim)
    
    baseFileName = cfg.stim.theImages(k).name;
    fullFileName = fullfile(cfg.path.images, baseFileName);
    cfg.stim.theImages(k).array = imread(fullFileName); % read the file
    
    % for each image generate an image texture and scale it appropriately
    % for the grid
    cfg.stim.theImages(k).org_size = size(cfg.stim.theImages(k).array); % original size of image
    cfg.stim.theImages(k).asp_rat =  min(cfg.stim.theImages(k).org_size(1:2))/max(cfg.stim.theImages(k).org_size(1:2));
    
    % some pre-allocation
    cfg.stim.theImages(k).scaled_rect = zeros(max(cfg.exp.n_stim),4,length(cfg.exp.n_stim));
    cfg.stim.mask.rect                = zeros(4,max(cfg.exp.n_stim),length(cfg.exp.n_stim));
    
    for i = 1:length(cfg.exp.n_stim) % create textures for each difficult level!
        
        cfg.stim.theImages(k).adj_size(i,2) = cfg.ptb.pixelScale(i)*0.9; % scale the image (height)
        cfg.stim.theImages(k).adj_size(i,1) = cfg.stim.theImages(k).adj_size(i,2)*cfg.stim.theImages(k).asp_rat; % scale the image (width)
        cfg.stim.theImages(k).texture(i) = Screen('MakeTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(k).array); % generate image textures
        
        % rescale image to grid
        cfg.stim.theImages(k).img_rect(i,:) = [0 0 cfg.stim.theImages(k).adj_size(i,1) cfg.stim.theImages(k).adj_size(i,1)];
        
        % generate an image rectangle for each grid location
        for nGrid = 1:cfg.exp.n_stim(i)
            
            cfg.stim.theImages(k).scaled_rect(nGrid,:,i) = CenterRectOnPointd(cfg.stim.theImages(k).img_rect(i,:), cfg.ptb.coords(i).coord(1,nGrid), cfg.ptb.coords(i).coord(2,nGrid));
            
            % create mask rectangles
            cfg.stim.mask.rect(:,nGrid,i) = CenterRectOnPointd(cfg.stim.mask.base_rect(i,:), cfg.ptb.coords(i).coord(1,nGrid), cfg.ptb.coords(i).coord(2,nGrid));
            
            
        end
        
        
        
    end
end

%% Instructions parameters
% =======================================================================
load([cfg.path.stim 'task_text.mat'], 'task_text');
cfg.ptb.instructions = task_text;

% Text parameters
cfg.ptb.text.n_lines                   = 2; % number of lines to wrap instructions at
cfg.ptb.text.size                      = 30; % what should be the size of texts
cfg.ptb.text.position                  = cfg.ptb.screenYpixels * 0.20; % Set text position
cfg.ptb.text.Col                       = cfg.ptb.black;
cfg.ptb.text.Colbis                    = cfg.ptb.white;
cfg.ptb.text.gray                      = [180 180 180]; % gray
cfg.ptb.text.ColAlternative            = [50 50 200]; % blue
cfg.ptb.text.bigFont                   = 25;
cfg.ptb.text.vSpacing                  = 3;

Screen('TextSize', cfg.ptb.PTBwindow, cfg.ptb.text.size);


% Confidence response parameters - exp02 doesn't use Likert Function,
% slideScale instead
cfg.ptb.conf.question = 'How confident are you in your guess?';
cfg.ptb.conf.endpoints = {'Not at all', 'Certain'};
cfg.ptb.conf.range = 2; % 0 - 100
cfg.ptb.conf.startposition = 'center';
cfg.ptb.conf.scalalength = 0.9;
cfg.ptb.conf.scalaposition = 0.9;
cfg.ptb.conf.device = 'mouse';
cfg.ptb.conf.slidercolor = [255 0 0]; % red
cfg.ptb.conf.scalacolor = [255 255 255]; % white
cfg.ptb.conf.displayposition = true;

% Cursor parameters
cfg.ptb.dot.size = 10;
cfg.ptb.dot.colour = [255 0 0];


%% Instructions
% =========================================================================
if cfg.do.instructions
    %General instructions : purpose of the experiment, incentives, time-lapse,
    %cursor, training
    for i = 1:31
        pic = Screen('MakeTexture', cfg.ptb.PTBwindow, stimuli.instructions{i});
        rect = CenterRectOnPoint(Screen('Rect',pic), cfg.ptb.xCenter, cfg.ptb.yCenter);
        Screen('DrawTexture', cfg.ptb.PTBwindow, pic, [], rect);
        Screen('Flip', cfg.ptb.PTBwindow);
        WaitSecs(0.1);
        waitBoutonJaune;
        Screen('Flip', cfg.ptb.PTBwindow);
        WaitSecs(0.1);
    end
end  % if instructions


%% Training
% =========================================================================
if cfg.do.training
    
    train_or_main = 'training';
    
    %% Generate permutations of pairs
    % value refers to the image number from stimuli/images
    % row 1 & 2 of column i are a pair
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
        cfg.exp.train(i).pair_perms = generate_pair_perms_v01(cfg, train_or_main, i);
    end
    %% Generate permutations image locations
    % 1:n_stim -> grid read left to right, top to bottom
    % EXAMPLE WITH A 4x4 GRID:
    % location_perms(1) = top left corner, locations_perms(16) = bottom right
    % corner -- value of location_perms refers to which image i.e. if
    % location_perms(4) = 8 then image 8 will be shown in the top right corner
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
        cfg.exp.train(i).location_perms = generate_location_perms_v01(cfg, train_or_main, i);
    end
    %% Generate order of images tested
    % as with pair_perms (:,1) is first pair, (:,2) is second pair etc...
    % function shuffles pairs for testing
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
        cfg.exp.train(i).test_perms = generate_test_perms_v02(cfg, train_or_main, i);
    end
    
    %% training ===========================================================
    training = cell(1, cfg.exp.train.trials);
    
    for nTrain = 1:cfg.exp.train.trials
        
        training{1,nTrain} = exp01_one_training_v01(cfg, nTrain, train_or_main);
        
    end
    
    % save!
    savewhere = [cfg.path.training 'training_' cfg.fname];
    save(savewhere, 'cfg', 'training');  % save training
    
end


%% Main Experiment
% =========================================================================
if cfg.do.main_experiment
    
    train_or_main = 'main';
    
    %% Generate permutations of pairs
    % value refers to the image number from stimuli/images
    % row 1 & 2 of column i are a pair
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
        cfg.exp.main(i).pair_perms = generate_pair_perms_v02(cfg, train_or_main, i);
    end
   

    %% Generate permutations image locations
    % 1:n_stim -> grid read left to right, top to bottom
    % EXAMPLE WITH A 4x4 GRID:
    % location_perms(1) = top left corner, locations_perms(16) = bottom right
    % corner -- value of location_perms refers to which image i.e. if
    % location_perms(4) = 8 then image 8 will be shown in the top right corner
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
       cfg.exp.main(i).location_perms = generate_location_perms_v02(cfg, train_or_main, i);
    end


    %% Generate order of images tested
    % as with pair_perms (:,1) is first pair, (:,2) is second pair etc...
    % function shuffles pairs for testing
    % =========================================================================
    for i = 1:length(cfg.exp.n_stim)
        cfg.exp.main(i).test_perms = generate_test_perms_v02(cfg, train_or_main, i);
    end

    
    %% main ===============================================================
    rec = cell(1, cfg.exp.n_trials);
    
    for nTrial = 1:cfg.exp.n_trials
        
        rec{1, nTrial} = exp02_one_trial_v01(cfg, nTrial, train_or_main);
        
    end
    
    
    % save!
    savewhere = [cfg.path.main_exp 'main_exp_' cfg.fname];
    save(savewhere, 'cfg', 'rec');  % save main
    
end
%%
sca; % close screen
