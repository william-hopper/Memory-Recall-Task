function [flip] = exp02_one_flip_v01(cfg, nTrial, trial)
%
% This function includes one flip of the cards.
%
% Author:   William Hopper
% Original: 06/02/2020

% flip.trial.flip.start_time = GetSecs;  % when did the show start
% flip.scriptname = mfilename('fullpath');  % save the name of this script


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
    case 'main'
        location_perms = cfg.exp.main(Diff).location_perms;
        pair_perms     = cfg.exp.main(Diff).pair_perms;
end

% mask all the locations
Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,:,Diff));

% draw the grid!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.coords(Diff).grid);

% flip
[~, T] = Screen('Flip', cfg.ptb.PTBwindow);

for nFlip = 1:cfg.exp.n_pairs(Diff)
    
    % which pair to show
    show = location_perms(trial_c(nTrial),:) == pair_perms(:,nFlip,trial_c(nTrial)); % logical vector of which two stimuli to show
    hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
    
    %% draw the image
    % cfg.stim.theImages(pair_perms(:,nFlip)).texture = which image
    % texture to show - so if pair_perms(:,nFlip) = [1 2] -> pair of 1s
    % pair_perms(:,nFlip) = [11 12] -> pair of 6s
    %
    % cfg.stim.theImages(pair_perms(:,nFlip)).scaled_rect(show(:,:),:)
    % - show indexes the spatial location of the image - there is a
    % scaled_rect for each grid location for each image
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(1,nFlip,trial_c(nTrial))).texture(Diff), [],...
        cfg.stim.theImages(pair_perms(1,nFlip,trial_c(nTrial))).scaled_rect(show(1,:),:,Diff), 0);
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(pair_perms(2,nFlip,trial_c(nTrial))).texture(Diff), [],...
        cfg.stim.theImages(pair_perms(2,nFlip,trial_c(nTrial))).scaled_rect(show(2,:),:,Diff), 0);
    
    % mask all the other locations
    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide,Diff));
    
    % draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.coords(Diff).grid);
    
    
    % flip at flip speed
    [~, T] = Screen('Flip', cfg.ptb.PTBwindow, T + cfg.exp.time.flip_speed);
    
end

WaitSecs(cfg.exp.time.flip_speed); % need to wait the flip speed on the last flip

end