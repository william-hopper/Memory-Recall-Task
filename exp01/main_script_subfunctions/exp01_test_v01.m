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

% test start time
T = GetSecs();

for nPair = 1:cfg.exp.n_pairs
    
    % which pair is being tested
    show = cfg.exp.location_perms(nTrial,:) == cfg.exp.test_perms(:,nPair,nTrial); % logical vector of which two stimuli are being tested (first row is stimuli shown)
    hide = ~show(1,:); % logical vector - hide all the other locations
    
    
    %% draw the test image
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.test_perms(1,nPair,nTrial)).texture, [],...
        cfg.stim.theImages(cfg.exp.test_perms(1,nPair,nTrial)).scaled_rect(show(1,:),:), 0);
    
    % mask all the other locations
    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
    
    % draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
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
            
            %                 mX > cfg.stim.theImages(cfg.exp.test_perms(2,nPair,nTrial)).scaled_rect(show(2,:),1) &&...
            %                 mX < cfg.stim.theImages(cfg.exp.test_perms(2,nPair,nTrial)).scaled_rect(show(2,:),3) &&...
            %                 mY > cfg.stim.theImages(cfg.exp.test_perms(2,nPair,nTrial)).scaled_rect(show(2,:),4) &&...
            %                 mY < cfg.stim.theImages(cfg.exp.test_perms(2,nPair,nTrial)).scaled_rect(show(2,:),2)
            %
            
            disp('Help')
            
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
            
            disp('dont Help')
            
            % wait for buttons to be released
            while any(buttons)
                [~, ~, buttons] = GetMouse(cfg.ptb.PTBwindow);
                WaitSecs(0.001);
            end
            
        end
        
    end
    
end

end