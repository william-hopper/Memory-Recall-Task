function [test] = exp02_test_v01(cfg, nTrial, trial)
%
% This function runs one recall test of the experiment
% participants are shown one image from each pair and must click the
% location of the other
%
% Author:   William Hopper
% Original: 06/02/2020

% Difficulty - for now just alternate
if length(cfg.exp.n_stim) > 1
    difficulty = ~mod(nTrial, 2); % 0 on odd trials/1 on even trials
    switch difficulty
        case 0
            Diff = 1;
        case 1
            Diff = 2;
    end
    
else
    Diff = 1;
end

% trial counter
trial_c = repelem(1:cfg.exp.n_trials/length(cfg.exp.n_pairs), 2);

% trial type changes location perms!
switch trial.type
    case 'training'
        location_perms = cfg.exp.train(Diff).location_perms;
        pair_perms     = cfg.exp.train(Diff).pair_perms;
        test_perms     = cfg.exp.train(Diff).test_perms;
    case 'main'
        location_perms = cfg.exp.main(Diff).location_perms;
        pair_perms     = cfg.exp.main(Diff).pair_perms;
        test_perms     = cfg.exp.main(Diff).test_perms;
end


test.RT = [0,0];

% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,:,Diff));

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.coords(Diff).grid);

[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

%% which pair is being tested
show = location_perms(trial_c(nTrial),:) == pair_perms(:,test_perms(trial_c(nTrial)),trial_c(nTrial));

% Draw the image
Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(1,test_perms(trial_c(nTrial)),trial_c(nTrial))).texture(Diff), [],...
    cfg.stim.theImages(pair_perms(1,test_perms(trial_c(nTrial)),trial_c(nTrial))).scaled_rect(show(1,:),:,Diff), 0);

switch cfg.do.cheat
    case 0
        hide = ~show(1,:); % logical vector - hide all the other locations
        
        % mask all the other locations
        Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide,Diff));
        
    case 1
        hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
        Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide,Diff));
        Screen('FillRect', cfg.ptb.PTBwindow, [0 1 0], cfg.stim.mask.rect(:,show(2,:),Diff));
        
end

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.coords(Diff).grid);

% Store image on offscreen window
Screen('CopyWindow', cfg.ptb.PTBwindow, cfg.ptb.PTBoffwindow);

% flip
[~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.response_speed);

%% response
click = 0;
while ~click
    
    % copy image of test window to onscreen
    Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
    
    % get mouse positions
    [mX, mY, buttons] = GetMouse(cfg.ptb.PTBwindow);
    
    % Draw a dot at the mouse location
    Screen('DrawDots', cfg.ptb.PTBwindow, [mX, mY], cfg.ptb.dot.size, cfg.ptb.dot.colour, [], 1);
    Screen('Flip', cfg.ptb.PTBwindow);
    
    
    % if the mX,mY coordinates are within the correct grid location
    if buttons(1) &&...
            mX > cfg.ptb.coords(Diff).grid(1,show(2,:)) &&...
            mX < cfg.ptb.coords(Diff).grid(3,show(2,:)) &&...
            mY > cfg.ptb.coords(Diff).grid(2,show(2,:)) &&...
            mY < cfg.ptb.coords(Diff).grid(4,show(2,:))
        
        % reaction time
        test.RT(2) = GetSecs() - T;
        test.RT(1) = 1; % correct response
        
        % highlight the clicked box
        for i = 1:cfg.exp.n_stim(Diff)
            if mX > cfg.ptb.coords(Diff).grid(1,i) &&...
                    mX < cfg.ptb.coords(Diff).grid(3,i) &&...
                    mY > cfg.ptb.coords(Diff).grid(2,i) &&...
                    mY < cfg.ptb.coords(Diff).grid(4,i)
                
                % dispplay image of test window to onscreen
                Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
                
                Screen('FrameRect', cfg.ptb.PTBwindow, [255, 255, 0],...
                    cfg.ptb.coords(Diff).grid(:,i), 8);
            end
        end
        
        while any(buttons)
            [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
            WaitSecs(0.001);
        end
        
        
        % break
        click = 1;
        
    elseif buttons(1)
        
        % reaction time
        test.RT(2) = GetSecs() - T;
        
        % highlight the clicked box
        for i = 1:cfg.exp.n_stim(Diff)
            if mX > cfg.ptb.coords(Diff).grid(1,i) &&...
                    mX < cfg.ptb.coords(Diff).grid(3,i) &&...
                    mY > cfg.ptb.coords(Diff).grid(2,i) &&...
                    mY < cfg.ptb.coords(Diff).grid(4,i)
                
                % display image of test window to onscreen
                Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
                
                Screen('FrameRect', cfg.ptb.PTBwindow, [255, 255, 0],...
                    cfg.ptb.coords(Diff).grid(:,i), 8);
                
            end
        end
        
        % wait for buttons to be released
        while any(buttons)
            [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
            WaitSecs(0.001);
        end
        
        % break
        click = 1;
        
    end
end

% Store image on offscreen window
Screen('CopyWindow', cfg.ptb.PTBwindow, cfg.ptb.PTBoffwindow);

% flip
Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(cfg.exp.time.highlight);

end