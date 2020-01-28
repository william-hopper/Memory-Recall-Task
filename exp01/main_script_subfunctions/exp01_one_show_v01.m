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
WaitSecs(3);


Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect);
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);


Screen('Flip', cfg.ptb.PTBwindow);
WaitSecs(1);

for nFlip = 1:cfg.exp.n_pairs
    
    show = cfg.exp.location_perms(nTrial,:) == cfg.exp.pair_perms(:,nFlip);
    hide = ~or(show(1,:),show(2,:));
    
    
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.pair_perms(1,nFlip)).texture, [], cfg.stim.theImages(cfg.exp.pair_perms(1,nFlip)).scaled_rect(:,:,show(1,:)), 0);
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(cfg.exp.pair_perms(2,nFlip)).texture, [], cfg.stim.theImages(cfg.exp.pair_perms(2,nFlip)).scaled_rect(:,:,show(2,:)), 0);
    
    Screen('FillRect', cfg.ptb.PTBwindow, 0.5, cfg.stim.mask.rect(:,hide));
    
    Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white, cfg.ptb.grid);
    
    Screen('Flip', cfg.ptb.PTBwindow);
    WaitSecs(0.5);
    
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