function test_perms = generate_test_perms_v01(cfg)
%
% This function generates nTrial sets of test permutations taken from
% pair_perms
%
% Author:   William Hopper
% Original: 30/01/2020

test_perms = zeros(2,cfg.exp.n_pairs,cfg.exp.n_trials);

for nTrial = 1:cfg.exp.n_trials
   
    % randomly shuffles the column order
    test_perms(:,:,nTrial) = cfg.exp.pair_perms(:,randperm(cfg.exp.n_pairs),nTrial);
    
end

end