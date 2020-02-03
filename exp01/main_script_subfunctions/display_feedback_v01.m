function [rec] = display_feedback_v01(cfg, trial, nTrial)
%
% This function displays the feedback following a test
% The participant is shown which pairs they got correct/incorrect
%
% Author:   William Hopper
% Original: 03/02/2020

% which ones did they get right?
correct_idx = trial.test.response(:,2) ~= 0;
incorrect_idx = ~correct_idx;

% what are the grid locations on this trial?
correct = cfg.exp.location_perms(nTrial,cfg.exp.pair_perms(:,correct_idx,nTrial));
incorrect = cfg.exp.location_perms(nTrial,cfg.exp.pair_perms(:,incorrect_idx,nTrial));

% display score out of n_pairs
trial_score = num2str(sum(trial.test.response(:,2)));

feedback_st = sprintf('%s', [trial_score '/8']);
DrawFormattedText(cfg.ptb.PTBwindow,feedback_st, cfg.ptb.screenXpixels*0.8, 'center', [1 1 1]);

% display images
for k = 1:cfg.exp.n_stim
    
    Screen('DrawTexture', cfg.ptb.PTBwindow, cfg.stim.theImages(k).texture, [],...
        cfg.stim.theImages(k).scaled_rect(cfg.exp.location_perms(nTrial,:) == k,:), 0);
    
end


    Screen('FrameRect', cfg.ptb.PTBwindow, [0 255 0], cfg.ptb.grid(:,correct), 10);
    Screen('FrameRect', cfg.ptb.PTBwindow, [255 0 0], cfg.ptb.grid(:,incorrect), 10);



Screen('Flip', cfg.ptb.PTBwindow);

WaitSecs(3);

end