function [test] = exp02_test_v01(cfg, nTrial, trial)
%
% This function runs one recall test of the experiment
% participants are shown one image from each pair and must click the
% location of the other
%
% Author:   William Hopper
% Original: 06/02/2020

% trial type changes location perms!
switch trial.type
    case 'training'
        location_perms = cfg.exp.train.location_perms;
        pair_perms     = cfg.exp.train.pair_perms;
        test_perms     = cfg.exp.train.test_perms;
    case 'main'
        location_perms = cfg.exp.location_perms;
        pair_perms     = cfg.exp.pair_perms;
        test_perms     = cfg.exp.test_perms;
end


test.RT = [0,0];

% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

%% which pair is being tested
show = location_perms(nTrial,:) == pair_perms(:,test_perms(nTrial),nTrial);

% Draw the image
Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(1,test_perms(nTrial),nTrial)).texture, [],...
    cfg.stim.theImages(pair_perms(1,test_perms(nTrial),nTrial)).scaled_rect(show(1,:),:), 0);

switch cfg.do.cheat
    case 0
        hide = ~show(1,:); % logical vector - hide all the other locations
        
        % mask all the other locations
        Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
        
    case 1
        hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
        Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
        Screen('FillRect', cfg.ptb.PTBwindow, [0 1 0], cfg.stim.mask.rect(:,show(2,:)));
        
end

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

% flip
[~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.response_speed, 1);

%% response
click = 0;
while ~click
    
    % get mouse positions
    [mX, mY, buttons] = GetMouse(cfg.ptb.PTBwindow);
    
    % if the mX,mY coordinates are within the correct grid location
    if buttons(1) &&...
            mX > cfg.ptb.grid(1,show(2,:)) &&...
            mX < cfg.ptb.grid(3,show(2,:)) &&...
            mY > cfg.ptb.grid(2,show(2,:)) &&...
            mY < cfg.ptb.grid(4,show(2,:))
        
        % reaction time
        test.RT(2) = GetSecs() - T;
        test.RT(1) = 1; % correct response
        
        % highlight the clicked box
        for i = 1:cfg.exp.n_stim
            if mX > cfg.ptb.grid(1,i) &&...
                    mX < cfg.ptb.grid(3,i) &&...
                    mY > cfg.ptb.grid(2,i) &&...
                    mY < cfg.ptb.grid(4,i)
                
                Screen('FrameRect', cfg.ptb.PTBwindow, [255, 255, 0],...
                    cfg.ptb.grid(:,i), 8);
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
        for i = 1:cfg.exp.n_stim
            if mX > cfg.ptb.grid(1,i) &&...
                    mX < cfg.ptb.grid(3,i) &&...
                    mY > cfg.ptb.grid(2,i) &&...
                    mY < cfg.ptb.grid(4,i)
                
                Screen('FrameRect', cfg.ptb.PTBwindow, [255, 255, 0],...
                    cfg.ptb.grid(:,i), 8);
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

% flip
Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(cfg.exp.time.highlight);

end