%% Rapid Serial Visual Presentation
% William Hopper
% REQUIRED:
% an2px.m
% arrow.m
% bestcondition.m
% checkperm.m
% gen_st_RSVP.m
% KbQueue.m
% RSVP_TaskParameters.m
%
%=====================================================================%
%%                               SET UP                              %%
%=====================================================================%

% clear workspace and screen
sca;
close all;
clearvars;


% Filename
% Subject Data
subid = 1;

scriptname = mfilename('fullpath');  % save the name of this script
timestamp = datestr(now, 30); % start time of the experiment
filename = [num2str(subid) '_' timestamp '.mat'];

% Load task parameters
load('testRSVPparams.mat')

% training data
data.RSVP.training.effort = zeros(n_train_phase,1);
data.RSVP.training.tar = zeros(40,4,n_train_phase); % target hit, target onset, participant response, RT
data.RSVP.training.FA = cell(n_train_phase,1); % FA, FA timing

% main data
data.RSVP.main.condition = zeros(n_offers,3); % bonus/effort level & phase
data.RSVP.main.engage = zeros(n_offers,2); % engage? if yes, why quit?
data.RSVP.main.optout = zeros(n_offers,2); % timing, difficulty level at optout
data.RSVP.main.optout_win = zeros(n_offers,2); % first/second optout window timing
data.RSVP.main.tar = zeros(40,4,n_offers); % target hit, target onset, participant response, RT
data.RSVP.main.FA = cell(n_offers,1); % FA, FA timing

save(filename, 'data');

% Some default settings for setting up Psychtoolbox
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Colors
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Choose background colour
backgroundColour = white*0.8;

% Open window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, backgroundColour);


% Get screen infos
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
screenCenter = [xCenter yCenter].';


% Text Formatting
Screen('TextFont', window, 'Times New Roman');
Screen('TextSize', window, font_size);
Screen('TextStyle', window, 1);

% position vectors
posStd = zeros(2,ns_Std+1,2); % non-target (:,:,1) = left; (:,:,2) = right
posStd_R = zeros(2,ns_Std+1); % non-target including right target stream
posTar = zeros(2,ns_Tar);   % target
posSwi = zeros(2,ns_Swi);   % switch

% generate random character sequence for non-target, target, and switch streams
MAX_ST_LENGTH = ceil(step_duration/stim_dur); % maximum number of symbols needed = trial duration divided by the frequency of stimulus presentation

% calculate the pixel offset of the target streams
CentreOffset = an2px(visual_angle,screen_distance,screenNumber);

% set-up for switch
for i = 1:ns_Swi
    posSwi = screenCenter;
end

% set-up for target
for i = 1:ns_Tar
    switch i
        case 1 % left target stream
            posTar(1,i) = posSwi(1) - CentreOffset;
            posTar(2,i) = posSwi(2);
        case 2 % right target stream
            posTar(1,i) = posSwi(1) + CentreOffset;
            posTar(2,i) = posSwi(2);
        otherwise
            error('Error: Failed initialising target streams');
    end
end

% set-up non-target
for i = 1:ns_Std+1
    switch i % working from left-to-right across the screen; x = 1; y = 2
        case 1 % furthest left
            posStd(1,i,:) = posSwi(1) - 1.5*CentreOffset;
            posStd(2,i,:) = posSwi(2);
        case 2 % left above
            posStd(1,i,:) = posSwi(1) - CentreOffset;
            posStd(2,i,:) = posSwi(2) + (CentreOffset/2);
        case 3 % left below
            posStd(1,i,:) = posSwi(1) - CentreOffset;
            posStd(2,i,:) = posSwi(2) - (CentreOffset/2);
        case 4 % furthest right
            posStd(1,i,:) = posSwi(1) + 1.5*CentreOffset;
            posStd(2,i,:) = posSwi(2);
        case 5 % right above
            posStd(1,i,:) = posSwi(1) + CentreOffset;
            posStd(2,i,:) = posSwi(2) + (CentreOffset/2);
        case 6 % right below
            posStd(1,i,:) = posSwi(1) + CentreOffset;
            posStd(2,i,:) = posSwi(2) - (CentreOffset/2);
        case 7 % target
            posStd(:,i,1) = posTar(:,2); % left
            posStd(:,i,2) = posTar(:,1); % right
        otherwise
            error('Error: Failed initialising non-target streams');
    end
end

% Scale coordinates based on font size
[Swix, Swiy, Swibbox] = DrawFormattedText(window, 'o', posSwi(1,1), posSwi(2,1), [1 1 1]); % draw initial letter to calculate font size
font_scale = (Swix - xCenter)/2;
font_box = [Swibbox(3)-Swibbox(1), Swibbox(4)-Swibbox(2)];
posStd = posStd - font_scale; % size 60 pt = 80 px
posTar = posTar - font_scale;
posSwi = posSwi - font_scale;
Screen('Flip', window);

%=====================================================================%
%%                               INSTRUCTIONS                        %%
%=====================================================================%

% initialise keyboard
% KbName('UnifyKeyNames');
space  = KbName('space');
escape = KbName('ESCAPE');
enter = KbName('Return');
left = KbName('LeftArrow');
right = KbName('RightArrow');
y = KbName('y');
n = KbName('n');
o = KbName('o');
response_key_idx = [enter, space];
keyList = zeros(1,256);
keyList(response_key_idx) = 1;

% initialise instruction screen
HideCursor();
menu = 1;
InInstructions = true;
n_lines = 4; % number of lines to display instructions over

% arrows for instruction screens
arrow_size = screenXpixels*0.05;
RightArrow_inst = arrow([screenXpixels*0.9, screenYpixels*0.9], 1, arrow_size);
LeftArrow_inst = arrow([screenXpixels*0.1, screenYpixels*0.9], -1, arrow_size);
Arrows_inst = [RightArrow_inst, LeftArrow_inst];

% initial direction arrow
RightArrow_ini = arrow([xCenter-(arrow_size/2), yCenter], 1, arrow_size);
LeftArrow_ini = arrow([xCenter+(arrow_size/2), yCenter], -1, arrow_size);
Arrows_ini = {LeftArrow_ini, RightArrow_ini};

swi_ch = ['>' '<'];

while InInstructions
    switch menu
        case 1
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst1)/n_lines); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst1, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            DrawFormattedText(window,TaskInst.arrows, 'center', screenYpixels*0.8, [0 0 0], wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, RightArrow_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 2;
            elseif keyCode(escape)
                break;
            end
            
        case 2
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst2)/n_lines); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst2, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 3;
            elseif keyCode(left)
                menu = 1;
            elseif keyCode(escape)
                break;
            end
            
        case 3
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst3)/n_lines); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst3, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 4;
            elseif keyCode(left)
                menu = 2;
            elseif keyCode(escape)
                break;
            end
            
        case 4
            % Description of the task
            % Focus on the eye symbol
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst4)/(n_lines+1)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst4(1:99), 'center',screenYpixels*0.05, [0 0 0],wrap,[],[],inst_line_spacing);
            DrawFormattedText(window,TaskInst.inst4(101:end), 'center',screenYpixels*0.75, [0 0 0],wrap,[],[],inst_line_spacing);
            
            %             Screen('DrawDots', window, posStd_L, 20, [1 0 0], [], 2);
            
            
            Screen('TextSize', window, font_size); % remember to reset to instruction size!
            % draw streams
            % Draw non-targets
            for i = 1:ns_Std+1 % +1 as one target stream inactive
                st_Std = 'zaBQWPN';
                [Stdx, Stdy, Stdbbox] = DrawFormattedText(window, st_Std(i), posStd(1,i,1), posStd(2,i,1), st_colour);
            end
            
            % Draw targets
            st_Tar = 'F';
            [Tarx, Tary, Tarbbox] = DrawFormattedText(window, st_Tar, posTar(1,1), posTar(2,1), st_colour);
            
            % Draw switch
            st_Swi = 'I';
            [Swix, Swiy, Swibbox] = DrawFormattedText(window, st_Swi, posSwi(1,1), posSwi(2,1), st_colour);
            
            % Draw eye symbol
            if eye
                Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
                % PUT EYE LOCATION
                eye_location = 'C:\Users\william.hopper\Google Drive\_DUAL MASTERS\[002] DM\[000] Perseverance\Matlab\RSVP\eyeinv2.png';
                eye_symbol = imread(eye_location);
                eye_texture = Screen('MakeTexture', window, eye_symbol);
                [s1, s2, s3] = size(eye_symbol);
                eye_aspratio = s2/s1;
                eye_height = screenYpixels*0.04;
                eye_width = eye_height*eye_aspratio;
                eye_rect = [0 0 eye_width eye_height];
                dstRect(:,1) = CenterRectOnPointd(eye_rect,xCenter,yCenter-(CentreOffset/4));
                Screen('DrawTexture', window, eye_texture, [], dstRect);
            end
            
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 5;
            elseif keyCode(left)
                menu = 3;
            elseif keyCode(escape)
                break;
            end
            
        case 5
            % Description of the task
            % Target streams
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst5)/(n_lines)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst5(1:187), 'center',screenYpixels*0.05, [0 0 0],wrap,[],[],inst_line_spacing);
            DrawFormattedText(window,TaskInst.inst5(189:end), 'center',screenYpixels*0.8, [0 0 0],wrap,[],[],inst_line_spacing);
            
            Screen('TextSize', window, font_size); % remember to reset to instruction size!
            % draw streams
            % Draw non-targets
            for i = 1:ns_Std+1 % +1 as one target stream inactive
                st_Std = 'KOBaPUR';
                [Stdx, Stdy, Stdbbox] = DrawFormattedText(window, st_Std(i), posStd(1,i,1), posStd(2,i,1), st_colour);
            end
            
            % Draw targets
            st_Tar = '7';
            [Tarx, Tary, Tarbbox] = DrawFormattedText(window, st_Tar, posTar(1,1), posTar(2,1), [1 0 0]);
            
            % Draw switch
            st_Swi = 'z';
            [Swix, Swiy, Swibbox] = DrawFormattedText(window, st_Swi, posSwi(1,1), posSwi(2,1), st_colour);
            
            % circle target streams
            baseRect = [0 0 4*font_box(1) 4*font_box(2)];
            centeredRect_L = CenterRectOnPointd(baseRect, xCenter-CentreOffset, yCenter+font_scale);
            centeredRect_R = CenterRectOnPointd(baseRect, xCenter+CentreOffset, yCenter+font_scale);
            rectColour = [1 0 0];
            Screen('FrameOval', window, rectColour, centeredRect_L, 5);
            Screen('FrameOval', window, rectColour, centeredRect_R, 5);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 6;
            elseif keyCode(left)
                menu = 4;
            elseif keyCode(escape)
                break;
            end
            
        case 6
            % Description of the task
            % Arrow indicating initial directions
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst6)/(n_lines)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst6, 'center',screenYpixels*0.05, [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw initial direction arrow
            Screen('DrawLines', window, LeftArrow_ini, 10, [0 0 1]);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 7;
            elseif keyCode(left)
                menu = 5;
            elseif keyCode(escape)
                break;
            end
            
        case 7
            % Description of the task
            % Central stream
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst7)/(n_lines+2)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst7(1:179), 'center',screenYpixels*0.05, [0 0 0],wrap,[],[],inst_line_spacing);
            DrawFormattedText(window,TaskInst.inst7(181:end), 'center',screenYpixels*0.75, [0 0 0],wrap,[],[],inst_line_spacing);
            
            Screen('TextSize', window, font_size); % remember to reset to instruction size!
            % draw streams
            % Draw non-targets
            for i = 1:ns_Std+1 % +1 as one target stream inactive
                st_Std = 'ESoqCRS';
                [Stdx, Stdy, Stdbbox] = DrawFormattedText(window, st_Std(i), posStd(1,i,1), posStd(2,i,1), st_colour);
            end
            
            % Draw targets
            st_Tar = 'P';
            [Tarx, Tary, Tarbbox] = DrawFormattedText(window, st_Tar, posTar(1,1), posTar(2,1), st_colour);
            
            % Draw switch
            st_Swi = '<';
            [Swix, Swiy, Swibbox] = DrawFormattedText(window, st_Swi, posSwi(1,1), posSwi(2,1), [1 0 0]);
            
            % circle central stream
            baseRect = [0 0 76 95];
            centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter+font_scale);
            rectColour = [1 0 0];
            Screen('FrameOval', window, rectColour, centeredRect, 5);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 8;
            elseif keyCode(left)
                menu = 6;
            elseif keyCode(escape)
                break;
            end
            
        case 8
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst8)/(n_lines+2)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst8, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 9;
            elseif keyCode(left)
                menu = 7;
            elseif keyCode(escape)
                break;
            end
            
        case 9
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst9)/(n_lines)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst9, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 10;
            elseif keyCode(left)
                menu = 8;
            elseif keyCode(escape)
                break;
            end
            
        case 10
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst10)/(n_lines+1)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst10, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 11;
            elseif keyCode(left)
                menu = 9;
            elseif keyCode(escape)
                break;
            end
            
            
        case 11
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst11)/(n_lines+1)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst11, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, Arrows_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(right)
                menu = 12;
            elseif keyCode(left)
                menu = 10;
            elseif keyCode(escape)
                break;
            end
            
        case 12
            % Description of the task
            Screen('TextSize', window, inst_font_size);
            wrap = ceil(length(TaskInst.inst12)/(n_lines-2)); % number of characters to wrap at for four lines
            DrawFormattedText(window,TaskInst.inst12, 'center','center', [0 0 0],wrap,[],[],inst_line_spacing);
            
            % draw arrows
            Screen('DrawLines', window, LeftArrow_inst, 5, [0 0 0])
            
            % flip
            Screen('Flip', window);
            
            % Next menu
            [secs, keyCode] = KbStrokeWait;
            if keyCode(space)
                InInstructions = false;
            elseif keyCode(left)
                menu = 11;
            elseif keyCode(escape)
                break;
            end
    end
end

%=====================================================================%
%%                           TRAINING PHASE                          %%
%=====================================================================%

% initialise
% randomise starting target size
TarSide_ini = repmat([1 2], 1, (n_train_phase/2));
TarSide_ini = TarSide_ini(randperm(length(TarSide_ini)));

if training
    % loop over number of training phases
    for train_phase = 1:n_train_phase
        
        % Display effort level
        Screen('TextSize', window, inst_font_size);
        DrawFormattedText(window,TaskTrain.cst, 'center',screenYpixels*0.35, [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,TaskTrain.lvl{training_effort(train_phase)}, 'center',screenYpixels*0.4, [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,TaskTrain.ready, 'center', screenYpixels*0.6, [0 0 0],50,[],[],inst_line_spacing);
        
        % flip
        Screen('Flip', window);
        WaitSecs(3);
        
        % reset text size
        Screen('TextSize', window, font_size);
        
        % low or high effort level
        EFF_lvl = training_effort(train_phase);
        
        % initial target side arrow
        % left = 1; right = 2;
        Screen('DrawLines', window, Arrows_ini{TarSide_ini(train_phase)}, 10, [0 0 1]);
        TarSide = TarSide_ini(train_phase);
        
        Screen('Flip', window);
        WaitSecs(stim_dur);
        t0 = GetSecs();
        
        tar_st = {}; % for indexing target locations
        stim_onset = zeros(1,MAX_ST_LENGTH*8);
        
        tar_t = zeros(1,n_Tar*8);     % initialise target timings
        tar_win = 0;                  % initialise target response window
        kb_tar_t = zeros(1,n_Tar*8);  % vector to hold target timings
        kb_ntar_t = [];               % initialise vector for false alarms
        pressCodeTime_tar = [];       
        pressCodeTime_ntar = [];
        tar_missed = 0;               % initialise targets missed
        
        % start keyboard queue and limit to only space and return
        KbQueue('start', {'space' 'Return'});
        KbQueue('flush');
        flip_t = GetSecs();
        
        tot_c = 1; % total number of stimulus presented counter
        tar_c = 0; % target stimulus counter
        
        InTask = true;
        
        while InTask % break if opt-out
            % loop over number of difficulty steps
            for diff_step = 1:8
                difficulty = EFF_lvl*train_Difficulty(train_phase,diff_step);
                
                [Std, Tar, Swi] = gen_st_RSVP(MAX_ST_LENGTH, symbols, difficulty);
                tar_st = [tar_st, Tar];
                InTask = true;
                st_c = 1; % number of stimulus presented within difficulty step counter
                while (st_c <= MAX_ST_LENGTH) % stop when n exceeds length of stimulus string
                    
                    % draw non-targets
                    for i = 1:ns_Std+1 % +1 as one target stream inactive
                        st_Std = Std(i,st_c);
                        [Stdx, Stdy, Stdbbox] = DrawFormattedText(window, st_Std, posStd(1,i,TarSide), posStd(2,i,TarSide), st_colour);
                    end
                    
                    % draw targets
                    st_Tar = Tar(st_c);
                    [Tarx, Tary, Tarbbox] = DrawFormattedText(window, st_Tar, posTar(1,TarSide), posTar(2,TarSide), st_colour);
                    
                    % draw switch
                    st_Swi = Swi(st_c);
                    if st_Swi == '3'
                        st_Swi = swi_ch(TarSide);
                    end
                    [Swix, Swiy, Swibbox] = DrawFormattedText(window, st_Swi, posSwi(1,1), posSwi(2,1), st_colour);
                    
                    
                    [flip_t, stim_onset(tot_c)] = Screen('Flip', window, flip_t+stim_dur);
                    
                    if st_Tar == '7'
                        tar_t(tar_c+1) = stim_onset(tot_c)-t0;
                        tar_c = tar_c + 1;
                        tar_win = GetSecs() + tar_response_time;
                    end
                    
                    
                    % collecting keyboard response
                    if (GetSecs() <= tar_win) % if still within the response window
                        pressCodeTime_tar = KbQueue('check', t0); % collect keyboard responses
                        
                        if ~isempty(pressCodeTime_tar)
                            
                            if any(pressCodeTime_tar(1,:) == enter)
                                optout_t = GetSecs() - t0;
                                %                         InTask = false;
                            end
                            pressCodeTime_tar = pressCodeTime_tar(2,pressCodeTime_tar(1,:) == space);
                            kb_tar_t(tar_c) = pressCodeTime_tar(1,end);
                        end
                        
                    end
                    
                    if (tar_win < GetSecs()) % if not within the response window
                        pressCodeTime_ntar = KbQueue('check', t0);
                        
                        if ~isempty(pressCodeTime_ntar)
                            
                            if any(pressCodeTime_ntar(1,:) == enter)
                                optout_t = GetSecs() - t0;
                                %                         InTask = false;
                            end
                            
                            pressCodeTime_ntar = pressCodeTime_ntar(2,pressCodeTime_ntar(1,:) == space);
                            kb_ntar_t(end+1) = pressCodeTime_ntar(1,end);
                        end
                        
                    end
                    
                    % if switch == 3, swap target sides
                    if st_Swi == '<' || st_Swi == '>'
                        TarSide = 3 - TarSide;
                    end
                    
                    st_c = st_c + 1;
                    tot_c = tot_c + 1;
                    
                end
                
            end
            InTask = false;
        end
        
        tar_hit_idx = find(kb_tar_t ~=0); % index of targets correctly responded to
        tar_miss_idx = find(kb_tar_t == 0); % index of targets missed
        
        
        tar_hit = num2str(numel(tar_hit_idx)); % number of correct target responses
        tar_hit_st = sprintf('%s',[tar_hit '/40']);
        
        tar_incor = num2str(numel(kb_ntar_t)); % number of false alarms
        tr_incor_st = sprintf('%s',tar_incor);
        
        Screen('TextSize', window, inst_font_size);
        DrawFormattedText(window,TaskTrain.results{1}, 'center', screenYpixels*0.3,  [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,TaskTrain.results{2}, 'center', screenYpixels*0.4,  [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,tar_hit_st,           'center', screenYpixels*0.45, [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,TaskTrain.results{3}, 'center', screenYpixels*0.6,  [0 0 0],50,[],[],inst_line_spacing);
        DrawFormattedText(window,tr_incor_st,          'center', screenYpixels*0.65, [0 0 0],[],[],[],inst_line_spacing);
        DrawFormattedText(window,TaskTrain.results{4}, 'center', screenYpixels*0.75, [0 0 0],[],[],[],inst_line_spacing);
        
        Screen('Flip',window);
        WaitSecs(15);
        
        DrawFormattedText(window,'Attention, le prochaine exercice est sur le point de commencer!', 'center', 'center', [0 0 0],[],[],[],inst_line_spacing);
        Screen('flip',window);
        WaitSecs(5);
        
        if train_phase == n_train_phase
            DrawFormattedText(window,TaskTrain.finish,'center','center', [0 0 0], 60,[],[],inst_line_spacing);
            
            % flip
            Screen('Flip', window);
            
            % wait for key to proceed to main task
            KbQueue('wait');
            KbQueue('stop');
        end
        
        
        %% store data
        data.RSVP.training.effort(train_phase,1) = EFF_lvl; % effort level
        data.RSVP.training.tar(tar_hit_idx,1,train_phase) = 1; % targets hit
        data.RSVP.training.tar(:,2,train_phase) = tar_t; % target onset time
        data.RSVP.training.tar(tar_hit_idx,3,train_phase) = kb_tar_t(tar_hit_idx); % target response time
        data.RSVP.training.tar(tar_hit_idx,4,train_phase) = data.RSVP.training.tar(tar_hit_idx,3,train_phase) - data.RSVP.training.tar(tar_hit_idx,2,train_phase); % target RT
        data.RSVP.training.FA{train_phase} = kb_ntar_t'; % false alarm timing
        
        % save
        save(filename, 'data');
        
        
    end
end
%=====================================================================%
%%                              MAIN TASK                            %%
%=====================================================================%

% load task parameters
load('realRSVPparams.mat');

% please wait 3 seconds for first offer
DrawFormattedText(window,TaskOffer.first,'center','center', [0 0 0],[],[],[],inst_line_spacing);
Screen('Flip', window);
WaitSecs(1);

% initialise target starting side
TarSide_ini = repmat([1 2], 1, (n_offers/2));
TarSide_ini = TarSide_ini(randperm(length(TarSide_ini)));

% reward/effort combinations
[A,B] = meshgrid(bonus_idx,effort_idx);
c = cat(2,A',B');
bon_eff_perm = reshape(c,[],2); % (:,1) = bonus; (:,2) = effort; (:,3) = phase offset
bon_eff_maxdiffTrials = bestcondition(n_offers,6);
phase_maxdiffTrials = repmat(1:8,1,6);
phase_swap = randi(2);

% success
success_idx = zeros(n_offers,1);
bonus_total = 0;

% loop over number of offers
for offer = 1:n_offers
    
    bon = bon_eff_perm(bon_eff_maxdiffTrials(offer),1); % offer bonus
    bon_st = sprintf('%s €', num2str(bonus(bon)));
    
    eff = bon_eff_perm(bon_eff_maxdiffTrials(offer),2); % offer effort
    eff_st = sprintf('%s',effort{eff});
    
    diff_phase = phase_maxdiffTrials(offer);
    
    offer_accept = NaN;
    result = NaN;
    fail_reason = NaN;
    optout_t = NaN;
    
    tar_t = zeros(1,n_Tar*8);
    tar_win = 0;
    kb_tar_t = zeros(1,n_Tar*8);
    kb_ntar_t = [];
    pressCodeTime_tar = [];
    pressCodeTime_ntar = [];
    tar_missed = 0;
    
    KbQueue('start', {'n' 'o'});
    KbQueue('flush');
    
    % Make offer to participant
    Screen('TextSize', window, inst_font_size);
    DrawFormattedText(window,[TaskOffer.count ' ' num2str(offer)],'center', screenYpixels*0.15, [0 0 0],[],[],[],inst_line_spacing);
    DrawFormattedText(window,TaskOffer.rwd,'center',screenYpixels*0.25, [0 0 0],[],[],[],inst_line_spacing);
    DrawFormattedText(window,[bon_st ' euros'],'center',screenYpixels*0.3, [0 0 0],[],[],[],inst_line_spacing);
    DrawFormattedText(window,TaskOffer.cst,'center',screenYpixels*0.45, [0 0 0],[],[],[],inst_line_spacing);
    DrawFormattedText(window,eff_st,'center',screenYpixels*0.5, [0 0 0],[],[],[],inst_line_spacing);
    DrawFormattedText(window,TaskOffer.inst, 'center', screenYpixels*0.65, [0 0 0],50,[],[],inst_line_spacing);
    
    % flip
    Screen('Flip', window);
    
    % wait for input
    [secs, keyCode] = KbQueue('wait');
    if keyCode == o
        % fill data array with accept decision;
        offer_accept = 1;
    elseif keyCode == n
        offer_accept = 0;
    end
    
    KbQueue('stop');
    
    %% offer accept
    if offer_accept
        
        DrawFormattedText(window,TaskOffer.ready, 'center', 'center', [0 0 0], 50, [], [], inst_line_spacing);
        
        Screen('Flip', window);
        WaitSecs(3); % wait 3 seconds
        Screen('TextSize', window, font_size);
        
        % initial target side arrow
        % left = 1; right = 2;
        Screen('DrawLines', window, Arrows_ini{TarSide_ini(offer)}, 10, [0 0 1]);
        TarSide = TarSide_ini(offer);
        
        Screen('Flip', window);
        WaitSecs(stim_dur);
        t0 = GetSecs();
        
        % optout window timing
        oo_step = oo_idx(diff_phase,:,phase_swap);
        
        if oo_step(1) ~= 0
            oo_win_1_min = oo_win(oo_step(1),1);
            oo_win_1_max = oo_win(oo_step(1),2);
        else
            oo_win_1_min = 0;
            oo_win_1_max = 0;
        end
        
        if oo_step(2) ~= 0
            oo_win_2_min = oo_win(oo_step(2),1);
            oo_win_2_max = oo_win(oo_step(2),2);
        else
            oo_win_2_min = 0;
            oo_win_2_max = 0;
        end
        
        oo_t_1 = randi([oo_win_1_min oo_win_1_max]) + t0;
        oo_t_2 = randi([oo_win_2_min oo_win_2_max]) + t0;
        
        tar_st = {}; % for indexing target locations
        stim_onset = zeros(1,MAX_ST_LENGTH*8);
        
%         tar_t = zeros(1,n_Tar*8);
%         tar_win = 0;
%         kb_tar_t = zeros(1,n_Tar*8);
%         kb_ntar_t = [];
%         pressCodeTime_tar = [];
%         pressCodeTime_ntar = [];
%         tar_missed = 0;
        
        KbQueue('start', {'space' 'Return'});
        KbQueue('flush');
        flip_t = t0;
        
        tot_c = 1; % total number of stimulus presented counter
        tar_c = 0; % target stimulus counter
        
        InTask = true;
        
        while InTask % break if optout
            
            % loop over number of difficulty steps
            for diff_step = 1:8
                difficulty = eff*Difficulty(diff_phase,diff_step);
                
                [Std, Tar, Swi] = gen_st_RSVP(MAX_ST_LENGTH, symbols, difficulty);
                tar_st = [tar_st, Tar];
                st_c = 1; % number of stimulus presented within difficulty step counter
                while (st_c <= MAX_ST_LENGTH) && InTask % stop when n exceeds length of stimulus string
                    tic;
                    %% Display
                    % draw non-targets
                    for i = 1:ns_Std+1 % +1 as one target stream inactive
                        st_Std = Std(i,st_c);
                        [Stdx, Stdy, Stdbbox] = DrawFormattedText(window, st_Std, posStd(1,i,TarSide), posStd(2,i,TarSide), st_colour);
                    end
                    
                    % draw targets
                    st_Tar = Tar(st_c);
                    [Tarx, Tary, Tarbbox] = DrawFormattedText(window, st_Tar, posTar(1,TarSide), posTar(2,TarSide), st_colour);
                    
                    % draw switch
                    st_Swi = Swi(st_c);
                    if st_Swi == '3'
                        st_Swi = swi_ch(TarSide);
                    end
                    [Swix, Swiy, Swibbox] = DrawFormattedText(window, st_Swi, posSwi(1,1), posSwi(2,1), st_colour);
                    
                    % Draw optout
                    Screen('TextSize', window, inst_font_size);
                    DrawFormattedText(window,TaskOffer.optout,'center',screenYpixels*0.8,[0 0 0],[],[],[],inst_line_spacing);
                    Screen('TextSize', window, font_size);
                    
                    [flip_t, stim_onset(tot_c)] = Screen('Flip', window, flip_t+stim_dur);
                    
                    if st_Tar == '7'
                        tar_t(tar_c+1) = stim_onset(tot_c)-t0;
                        tar_c = tar_c + 1;
                        tar_win = GetSecs() + tar_response_time;
                    end
                    
                    
                    % if switch == 3, swap target sides
                    if st_Swi == '<' || st_Swi == '>'
                        TarSide = 3 - TarSide;
                    end
                    
                    
                    %% collecting keyboard response
                    if (GetSecs() <= tar_win) % if still within the response window
                        pressCodeTime_tar = KbQueue('check', t0); % collect keyboard responses
                        
                        if ~isempty(pressCodeTime_tar)
                            
                            if any(pressCodeTime_tar(1,:) == enter)
                                optout_t = GetSecs() - t0;
                                result = 2; % optout
                                InTask = false;
                            end
                            
                            pressCodeTime_tar = pressCodeTime_tar(2,pressCodeTime_tar(1,:) == space);
                            
                            if ~isempty(pressCodeTime_tar)
                                kb_tar_t(tar_c) = pressCodeTime_tar(1,end);
                            end
                        end
                        
                    end
                    
                    if (tar_win < GetSecs()) % if not within the response window
                        pressCodeTime_ntar = KbQueue('check', t0);
                        
                        if ~isempty(pressCodeTime_ntar)
                            
                            if any(pressCodeTime_ntar(1,:) == enter)
                                optout_t = GetSecs() - t0;
                                result = 2; % optout
                                InTask = false;
                            end
                            
                            pressCodeTime_ntar = pressCodeTime_ntar(2,pressCodeTime_ntar(1,:) == space);
                            
                            if ~isempty(pressCodeTime_ntar)
                                kb_ntar_t(end+1) = pressCodeTime_ntar(1,end);
                            end
                        end
                        
                    end
                    
                    
                    
                    %% performance threshold
                    tar_missed = numel(find(kb_tar_t(1:tar_c) == 0));
                    if (tar_missed > 5) % if performance drops below 90% (5/40) --> opt-out
                        result = 1;
                        fail_reason = 1;
                        optout_t = GetSecs() - t0;
                        %                         InTask = false;
                    end
                    
                    if (length(kb_ntar_t) > 8) % if too many false alarms (more than 5) optout
                        result = 1;
                        fail_reason = 2;
                        optout_t = GetSecs() - t0;
                        %                         InTask = false;
                    end
                    
                    st_c = st_c + 1;
                    tot_c = tot_c + 1;
                    
                    %% optout window
                    
                    % first window
                    if (oo_t_1 <= GetSecs()) && (GetSecs() <= (oo_t_1 + oo_response_time))
                        
                        delay(1) = GetSecs() - oo_t_1;
                        
                        Screen('TextSize', window, inst_font_size);
                        DrawFormattedText(window,TaskMain.optout,'center',screenYpixels*0.5,[0 0 0],[],[],[],inst_line_spacing);
                        Screen('TextSize', window, font_size);
                        
                        Screen('Flip', window);
                        
                        while (GetSecs() <= (oo_t_1 + oo_response_time))
                            [a,b,keyCode] = KbCheck;
                            if keyCode(enter)
                                optout_t = GetSecs() - t0;
                                result = 2;
                                InTask = false;
                                break
                            end
                        end
                        
                        % Draw arrow
                        Screen('DrawLines', window, Arrows_ini{TarSide}, 10, [0 0 1]);
                        
                        Screen('Flip', window);
                        WaitSecs(stim_dur);
                        
                    end
                    
                    % second window
                    if (oo_t_2 <= GetSecs()) && (GetSecs() <= (oo_t_2 + oo_response_time))
                        
                        delay(2) = GetSecs() - oo_t_2;
                        
                        Screen('TextSize', window, inst_font_size);
                        DrawFormattedText(window,TaskMain.optout,'center',screenYpixels*0.5,[0 0 0],[],[],[],inst_line_spacing);
                        Screen('TextSize', window, font_size);
                        
                        Screen('Flip', window);
                        
                        while (GetSecs() <= (oo_t_2 + oo_response_time))
                            [a,b,keyCode] = KbCheck;
                            if keyCode(enter)
                                optout_t = GetSecs() - t0;
                                result = 2;
                                InTask = false;
                                break
                            end
                        end
                        
                        % Draw arrow
                        Screen('DrawLines', window, Arrows_ini{TarSide}, 10, [0 0 1]);
                        
                        Screen('Flip', window);
                        WaitSecs(stim_dur);
                        
                    end
                    
                    
                    % third window
                    %                     if (oo_t_3 <= GetSecs()) && (GetSecs() <= (oo_t_3 + oo_response_time))
                    %
                    %                         delay(3) = GetSecs() - oo_t_3;
                    %
                    %                         Screen('TextSize', window, inst_font_size);
                    %                         DrawFormattedText(window,TaskMain.optout,'center',screenYpixels*0.5,[0 0 0],[],[],[],inst_line_spacing);
                    %                         Screen('TextSize', window, font_size);
                    %
                    %                         Screen('Flip', window);
                    %
                    %                         while (GetSecs() <= (oo_t_3 + oo_response_time))
                    %                             [a,b,keyCode] = KbCheck;
                    %                             if keyCode(enter)
                    %                                 optout_t = GetSecs() - t0;
                    %                                 result = 2;
                    %                                 InTask = false;
                    %                                 break
                    %                             end
                    %                         end
                    %
                    %                     end
                    
                    second(tot_c) = toc;
                end
                
                % check still in task
                if ~InTask
                    break;
                end
                
            end
            
            % round completed
            if (diff_step == 8)
                if (result ~= 1) && (result ~= 2) % if not failure or optout
                    result = 3;
                    InTask = false;
                end
            end
        end
        
        if diff_phase == 7
            phase_swap = 3 - phase_swap;
        end
        
    else
        
        % make participant wait remaining amount of time
        for i = 1:max_round_duration
            Screen('TextSize', window, inst_font_size);
            
            sec = max_round_duration - i;
            [nx, ny, nbbox] = DrawFormattedText(window,TaskOffer.wait, 'center','center', [0 0 0],[],[],[],inst_line_spacing);
            [ox, oy, obbox] = DrawFormattedText(window,num2str(round(sec)),xCenter-50,nbbox(4),[0 0 0],[],[],[],inst_line_spacing);
            DrawFormattedText(window, ' secondes',ox,oy,[0 0 0],[],[],[],3);
            
            % flip screen
            Screen('Flip', window);
            
            WaitSecs(1);
            result = 4;
        end
    end
    
    switch result
        
        %         case 1 % Failed Screen
        %             for i = 1:(max_round_duration-round(optout_t)) % amount of time remaining
        %
        %                 Screen('TextSize', window, inst_font_size);
        %                 sec = (max_round_duration-round(optout_t)) - i;
        %                 [nx, ny, nbbox] = DrawFormattedText(window,TaskResults.fail{fail_reason}, 'center',screenYpixels*0.35, [0 0 0],[],[],[],inst_line_spacing);
        %                 [ox, oy, obbox] = DrawFormattedText(window,num2str(sec),xCenter-50,nbbox(4),[0 0 0],[],[],[],inst_line_spacing);
        %                 DrawFormattedText(window, ' secondes',ox,oy,[0 0 0],[],[],[],inst_line_spacing);
        %
        %                 % flip screen
        %                 Screen('Flip', window);
        %
        %                 WaitSecs(1);
        %             end
        
        
        case {1, 2} % Opt-out Screen
            for i = 1:(max_round_duration-round(optout_t)) % amount of time remaining
                
                Screen('TextSize', window, inst_font_size);
                sec = (max_round_duration-round(optout_t)) - i;
                [nx, ny, nbbox] = DrawFormattedText(window,TaskResults.optout, 'center',screenYpixels*0.35, [0 0 0],[],[],[],inst_line_spacing);
                [ox, oy, obbox] = DrawFormattedText(window,num2str(round(sec)),xCenter-50,nbbox(4),[0 0 0],[],[],[],inst_line_spacing);
                DrawFormattedText(window, ' secondes',ox,oy,[0 0 0],[],[],[],inst_line_spacing);
                
                % flip screen
                Screen('Flip', window);
                
                WaitSecs(1);
            end
            
            data.RSVP.main.optout(offer,1) = optout_t; % optout timining
            data.RSVP.main.optout(offer,2) = difficulty; % optout difficulty phase
            
        case 3 % Results Screen
            
            Screen('TextSize', window, inst_font_size);
            DrawFormattedText(window,TaskResults.success, 'center', 'center', [0 0 0],[],[],[],inst_line_spacing);
            
            success_idx(offer,1) = 1;
            switch bon
                case 1
                    rew = 0.5;
                case 2
                    rew = 1;
                case 3
                    rew = 2;
            end
            
            bonus_total = bonus_total + rew;
            
            % flip screen
            Screen('Flip', window);
            WaitSecs(5);
            
        case 4  % Did not engage
            % do nothing and go to next offer
            
    end
    
    if offer == n_offers
        KbQueue('stop');
    end
    
    %% store data
    tar_hit_idx = find(kb_tar_t ~=0); % index of targets correctly responded to
    tar_miss_idx = find(kb_tar_t == 0); % index of targets missed
    
    data.RSVP.main.condition(offer,1) = bon; % bonus
    data.RSVP.main.condition(offer,2) = eff; % effort level
    data.RSVP.main.condition(offer,3) = diff_phase; % phase offset
    data.RSVP.main.engage(offer,1) = offer_accept; % not engage = 0; engage = 1;
    data.RSVP.main.engage(offer,2) = result; % fail = 1; optout = 2; success = 3; not engage = 4;
    data.RSVP.main.optout_win(offer,1) = oo_t_1 - t0; % first oo window timing
    data.RSVP.main.optout_win(offer,2) = oo_t_2 - t0; % second oo window timing
    data.RSVP.main.tar(tar_hit_idx,1,offer) = 1; % targets hit
    data.RSVP.main.tar(:,2,offer) = tar_t; % target onset time
    data.RSVP.main.tar(tar_hit_idx,3,offer) = kb_tar_t(tar_hit_idx); % target response time
    data.RSVP.main.tar(tar_hit_idx,4,offer) = data.RSVP.main.tar(tar_hit_idx,3,offer) - data.RSVP.main.tar(tar_hit_idx,2,offer); % target RT
    data.RSVP.main.FA{offer} = kb_ntar_t'; % false alarm timing
    
    % save
    save(filename, 'data');
    
end
data.RSVP.main.bonus = floor(bonus_total/4); % total bonus earned


%% save and thank you
save(filename, 'data');

KbQueue('start', {'ESCAPE'});
KbQueue('flush');


% Thank you screen
Screen('TextSize', window, inst_font_size);
DrawFormattedText(window,TaskResults.finish, 'center', screenYpixels*0.3, [0 0 0],[],[],[],inst_line_spacing);
DrawFormattedText(window,['En bonus, vous avez gagné: ' num2str(bonus_total) ' euros'], 'center', screenYpixels*0.5, [0 0 0],[],[],[],inst_line_spacing);

Screen('Flip', window);

KbQueue('wait');
sca;