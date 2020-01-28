function [pair_perms] = generate_pair_perms_v01(cfg)
%
% This function generates nTrial sets of nStim/2 pairs of stimuli
%
% Author:   William Hopper
% Original: 15/01/2020

pair_perms = zeros(2, cfg.exp.n_pairs, cfg.exp.n_trials);

for nTrial = 1:cfg.exp.n_trials
    
    pair_perms(:,:,nTrial) = reshape(randperm(16), 2, cfg.exp.n_pairs);
    
end

end