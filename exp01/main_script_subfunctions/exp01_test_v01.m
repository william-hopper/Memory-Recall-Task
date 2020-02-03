function [test] = exp01_test_v01(cfg, nTrial)
%
% This function runs one recall test of the experiment
% participants are shown one image from each pair and must click the
% location of the other within cfg.exp.response_speed
% no feedback is given to prevent systematic searching
%
% Author:   William Hopper
% Original: 30/01/2020

% rec.response(:,1) = response or not? (:,2) = correct response or not?
test.response = zeros(cfg.exp.n_pairs, 2);
test.RT = zeros(cfg.exp.n_pairs,1);

% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

diff = ~mod(nTrial, 2); % 0 on odd trials/1 on even trials

for nPair = 1:cfg.exp.n_pairs
    
    % which pair is being tested
    show = cfg.exp.location_perms(nTrial,:) == cfg.exp.test_perms(:,nPair,nTrial); % logical vector of which two stimuli are being tested (first row is stimuli shown)
    hide = ~show(1,:); % logical vector - hide all the other locations
    
    % draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
    
    
    switch diff
        case 0 % 'easy' - no mask - 1st of pair highlighted
            
            % draw the test image
            for k = 1:cfg.exp.n_stim
                Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.location_perms(nTrial,k)).texture, [],...
                    cfg.stim.theImages(cfg.exp.location_perms(nTrial,k)).scaled_rect(k,:), 0);
            end
            
            % draw grid and highlight first of test pair
            Screen('FrameRect', cfg.ptb.PTBwindow, [0 191 255], cfg.ptb.grid(:,show(1,:)), 10);
            
            switch cfg.do.cheat
                case 0
                case 1
                    Screen('FrameRect', cfg.ptb.PTBwindow, [0 255 0], cfg.ptb.grid(:,show(2,:)), 10)
                    
            end
        case 1 % 'hard' - all but test image masked
            
            % draw the test image
            Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.test_perms(1,nPair,nTrial)).texture, [],...
                cfg.stim.theImages(cfg.exp.test_perms(1,nPair,nTrial)).scaled_rect(show(1,:),:), 0);
            
            switch cfg.do.cheat
                case 0
                    
                    % mask all the other locations
                    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
                    
                case 1
                    
                    hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
                    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
                    Screen('FillRect', cfg.ptb.PTBwindow, [0 1 0], cfg.stim.mask.rect(:,show(2,:)));
                    
            end
    end
    
    
    % flip
    [~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.response_speed);
    
    % check for mouse click
    % while within response window
    while GetSecs() <= (T + cfg.exp.time.response_speed) && test.response(nPair,1) == 0
        
        % get mouse positions
        [mX, mY, buttons] = GetMouse(cfg.ptb.PTBwindow);
        
        
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
            
            % wait for buttons to be released
            while any(buttons)
                [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
                WaitSecs(0.001);
            end
            
        end
        
    end
    
end

end