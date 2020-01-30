function [pair_perms] = generate_pair_perms_v01(cfg)
%
% This function generates nTrial sets of nStim/2 pairs of stimuli
%
% Author:   William Hopper
% Original: 15/01/2020

% pre-allocate
pair_perms = zeros(2, cfg.exp.n_pairs, cfg.exp.n_trials);

% geenrate pairs for nTrials
for nTrial = 1:cfg.exp.n_trials
    
    % pair_perms(1,1,nTrial) + pair_perms(2,1,nTrial) = first pair
    % pair_perms(1,2,nTrial) + pair_perms(2,2,nTrial) = second pair etc..
    pair_perms(:,:,nTrial) = reshape(randperm(cfg.exp.n_stim), 2, cfg.exp.n_pairs);
    
end

end