function [flip] = exp01_one_flip_v01(cfg, nTrial, trial)
%
% This function includes one flip of the cards.
%
% Author:   William Hopper
% Original: 10/01/2020

% flip.trial.flip.start_time = GetSecs;  % when did the show start
% flip.scriptname = mfilename('fullpath');  % save the name of this script

% trial type changes location perms!
switch trial.type
    case 'training'
        location_perms = cfg.exp.train.location_perms;
        pair_perms     = cfg.exp.train.pair_perms;
    case 'main'
        location_perms = cfg.exp.location_perms;
        pair_perms     = cfg.exp.pair_perms;
end


% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);

% draw the total flip number in the top right of the screen
flip_num = num2str(trial.show.flip_counter);

DrawFormattedText(cfg.ptb.PTBwindow, [cfg.ptb.instructions.flip_num flip_num],...
    cfg.ptb.screenXpixels*0.8,cfg.ptb.screenYpixels*0.1, cfg.ptb.white, length(cfg.ptb.instructions.flip_num));


[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

for nFlip = 1:cfg.exp.n_pairs
    
    % which pair to show
    show = location_perms(nTrial,:) == pair_perms(:,nFlip,nTrial); % logical vector of which two stimuli to show
    hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
    
    %% draw the image
    % cfg.stim.theImages(pair_perms(:,nFlip)).texture = which image
    % texture to show - so if pair_perms(:,nFlip) = [1 2] -> pair of 1s
    % pair_perms(:,nFlip) = [11 12] -> pair of 6s
    %
    % cfg.stim.theImages(pair_perms(:,nFlip)).scaled_rect(show(:,:),:)
    % - show indexes the spatial location of the image - there is a
    % scaled_rect for each grid location for each image
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(1,nFlip,nTrial)).texture, [],...
        cfg.stim.theImages(pair_perms(1,nFlip,nTrial)).scaled_rect(show(1,:),:), 0);
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(2,nFlip,nTrial)).texture, [],...
        cfg.stim.theImages(pair_perms(2,nFlip,nTrial)).scaled_rect(show(2,:),:), 0);
    
    % mask all the other locations
    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
    
    % draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
    % draw the total flip number in the top right of the screen
    flip_num = num2str(trial.show.flip_counter);
    
    DrawFormattedText(cfg.ptb.PTBwindow, [cfg.ptb.instructions.flip_num flip_num],...
        cfg.ptb.screenXpixels*0.8,cfg.ptb.screenYpixels*0.1, cfg.ptb.white, length(cfg.ptb.instructions.flip_num));
    
    
    % flip at flip speed
    [~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.flip_speed);
    
end

WaitSecs(cfg.exp.time.flip_speed); % need to wait the flip speed on the last flip

end