function [pair_perms] = generate_pair_perms_v01(cfg)
%
% This function generates nTrial sets of nStim/2 pairs of stimuli
%
% Author:   William Hopper
% Original: 15/01/2020

% pre-allocate
pair_perms = zeros(2, cfg.exp.n_pairs, cfg.exp.n_trials);

a = [1 3 5 7 9 11 13 15; 2 4 6 8 10 12 14 16];

% generate pairs for nTrials
for nTrial = 1:cfg.exp.n_trials
    
    % pair_perms(1,1,nTrial) + pair_perms(2,1,nTrial) = first pair
    % pair_perms(1,2,nTrial) + pair_perms(2,2,nTrial) = second pair etc..
    %     pair_perms(:,:,nTrial) = reshape(randperm(cfg.exp.n_stim), 2, cfg.exp.n_pairs);
    
    
    pair_perms(:,:,nTrial) = a(:,randperm(cfg.exp.n_pairs));
    
    
end

end