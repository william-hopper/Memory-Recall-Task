function [location_perms] = generate_location_perms_v01(cfg, train_or_main)
%
% This function generates nTrial sets of location permutations from 1:nStim 
% 1:n_stim -> read grid left to right, top to bottom
%
% Author:   William Hopper
% Original: 16/01/2020

switch train_or_main
    case 'training'
        n_trials = cfg.exp.train.trials;
    case 'main'
        n_trials = cfg.exp.n_trials;
end

location_perms = repmat(1:cfg.exp.n_stim, [n_trials, 1]);

for nTrial = 1:n_trials
    
location_perms(nTrial,:) = location_perms(nTrial,randperm(cfg.exp.n_stim));

end