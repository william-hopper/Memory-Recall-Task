function [rec] = exp01_one_show_v01(cfg, nTrial)
%
% This function includes one show of the cards.
%
% Author:   William Hopper
% Original: 10/01/2020

rec.trial.show.start_time = GetSecs;  % when did the show start
rec.scriptname = mfilename('fullpath');  % save the name of this script


for k = 1:cfg.exp.n_stim
    
    % Draw images to screen
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(k).texture, [], cfg.stim.theImages(k).scaled_rect(:,:,cfg.exp.location_perms(nTrial,:) == k), 0);
    
end

% draw grid - do this each flip!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);


Screen('Flip', cfg.ptb.PTBwindow);
WaitSecs(0.5);


Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);


Screen('Flip', cfg.ptb.PTBwindow);
WaitSecs(0.5);

for nFlip = 1:cfg.exp.n_pairs
    
    % which pair to show
    show = cfg.exp.location_perms(nTrial,:) == cfg.exp.pair_perms(:,nFlip,nTrial); % logical vector of which two stimuli to show
    hide = ~or(show(1,:),show(2,:)); % logical vector of ~show i.e. all the ones to hide
    
    % draw the image
    % cfg.stim.theImages(cfg.exp.pair_perms(:,nFlip)).texture = which image
    % texture to show - so if pair_perms(:,nFlip) = [6 3] -> images 6 and 3
    %
    % cfg.stim.theImages(cfg.exp.pair_perms(:,nFlip)).scaled_rect(:,:,show(:,:))
    % - show indexes the spatial location of the image - there is a
    % scaled_rect for each grid location for each image
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.pair_perms(1,nFlip,nTrial)).texture, [],...
        cfg.stim.theImages(cfg.exp.pair_perms(1,nFlip,nTrial)).scaled_rect(:,:,show(1,:)), 0);
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.pair_perms(2,nFlip,nTrial)).texture, [],...
        cfg.stim.theImages(cfg.exp.pair_perms(2,nFlip,nTrial)).scaled_rect(:,:,show(2,:)), 0);
    
    % mask all the other locations (
    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
    
    %draw the grid!
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    WaitSecs(cfg.exp.time.flip_speed);
    
end

for k = 1:cfg.exp.n_stim
    
    image = cfg.exp.location_perms(nTrial,k);
    
    % Draw images to screen
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(image).texture, [], cfg.stim.theImages(image).scaled_rect(:,:,k), 0);
    
end

% draw grid - do this each flip!
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);


Screen('Flip', cfg.ptb.PTBwindow);

end