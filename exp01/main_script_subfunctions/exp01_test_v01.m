function [test] = exp01_test_v01(cfg, nTrial, trial)
%
% This function runs one recall test of the experiment
% participants are shown one image from each pair and must click the
% location of the other within cfg.exp.response_speed
% no feedback is given to prevent systematic searching
%
% Author:   William Hopper
% Original: 30/01/2020

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

% rec.response(:,1) = response or not? (:,2) = correct response or not?
test.response = zeros(cfg.exp.n_pairs, 2);
test.RT = zeros(cfg.exp.n_pairs,1);

% pre-allocate
test.cor_grid = false(1,16);

% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

% diff = ~mod(nTrial, 2); % 0 on odd trials/1 on even trials
diff = 0;
for nPair = 1:cfg.exp.n_pairs
    
    % which pair is being tested
    switch diff
        case 0 % test phase in the same order
            
            show = location_perms(nTrial,:) == pair_perms(:,nPair,nTrial);
            hide = ~show(1,:); % logical vector - hide all the other locations
            
            Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(1,nPair,nTrial)).texture, [],...
                cfg.stim.theImages(pair_perms(1,nPair,nTrial)).scaled_rect(show(1,:),:), 0);
            
            
        case 1 % test phase random order
            
            show = location_perms(nTrial,:) == test_perms(:,nPair,nTrial); % logical vector of which two stimuli are being tested (first row is stimuli shown)
            hide = ~show(1,:); % logical vector - hide all the other locations
            
            % draw the test image
            Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(test_perms(1,nPair,nTrial)).texture, [],...
                cfg.stim.theImages(test_perms(1,nPair,nTrial)).scaled_rect(show(1,:),:), 0);
            
    end
    
    switch cfg.do.cheat
        case 0
            
            % mask all the other locations
            Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
            
        case 1
            
            hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
            Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
            Screen('FillRect', cfg.ptb.PTBwindow, [0 1 0], cfg.stim.mask.rect(:,show(2,:)));
            
    end
    
    % draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
    % Store image on offscreen window
    Screen('CopyWindow', cfg.ptb.PTBwindow, cfg.ptb.PTBoffwindow);
    
    % flip
    [~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.response_speed);
    
    % check for mouse click
    % while within response window
    while GetSecs() <= (T + cfg.exp.time.response_speed) && test.response(nPair,1) == 0
        
        % copy image of test window to onscreen
        Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
        
        % get mouse positions
        [mX, mY, buttons] = GetMouse(cfg.ptb.PTBwindow);
        
        % Draw a dot at the mouse location
        Screen('DrawDots', cfg.ptb.PTBwindow, [mX, mY], cfg.ptb.dot.size, cfg.ptb.dot.colour, [], 1);
        Screen('Flip', cfg.ptb.PTBwindow);
        
        
        % if the mX,mY coordinates are within the correct grid location
        if buttons(1) &&...
                mX > cfg.ptb.grid(1,show(2,:)) &&...
                mX < cfg.ptb.grid(3,show(2,:)) &&...
                mY > cfg.ptb.grid(2,show(2,:)) &&...
                mY < cfg.ptb.grid(4,show(2,:))
            
            % reaction time
            test.RT(nPair) = GetSecs() - T;
            
            % correct response
            test.response(nPair,1) = 1;
            test.response(nPair,2) = 1;
            
            % grid location
            test.cor_grid(show(1,:)) = true;
            test.cor_grid(show(2,:)) = true;
            
            % copy image of test window to onscreen
            Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
            
            % wait for buttons to be released
            while any(buttons)
                [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
                WaitSecs(0.001);
            end
            
            
            
            % else
        elseif buttons(1)
            
            % reaction time
            test.RT(nPair) = GetSecs() - T;
            
            % incorrect response but still a response
            test.response(nPair,1) = 1;
            test.response(nPair,2) = 0;
            
            % copy image of test window to onscreen
            Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
            
            % wait for buttons to be released
            while any(buttons)
                [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
                WaitSecs(0.001);
            end
            
        end
        
    end
    
    % copy image of test window to onscreen
    Screen('CopyWindow', cfg.ptb.PTBoffwindow, cfg.ptb.PTBwindow);
    
    % flip
    Screen('Flip', cfg.ptb.PTBwindow);
    
end

% Wait time remaining after last pair
WaitSecs(cfg.exp.time.response_speed - test.RT(nPair));

end