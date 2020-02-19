function test_perms = generate_test_perms_v01(cfg,train_or_main)
%
% This function generates nTrial sets of test permutations taken from
% pair_perms
%
% Author:   William Hopper
% Original: 30/01/2020

switch train_or_main
    case 'training'
        n_trials   = cfg.exp.train.trials;
        pair_perms = cfg.exp.train.pair_perms;
    case 'main'
        n_trials   = cfg.exp.n_trials;
        pair_perms = cfg.exp.pair_perms;
end

test_perms = zeros(2,cfg.exp.n_pairs,n_trials);

for nTrial = 1:n_trials
    
    % randomly shuffles the column order
    test_perms(:,:,nTrial) = pair_perms(:,randperm(cfg.exp.n_pairs),nTrial);
    
end

end