function [test_perms] = generate_test_perms_v02(cfg, train_or_main, i)
%
% Version 2 of the generate test pairs function. In Exp02 participants are
% only test on one random pair so this function only generates nTrial pairs
% All pairs will be selected an equal number of times
%
% Author:   William Hopper
% Original: 06/02/2020

switch train_or_main
    case 'training'
        n_trials   = cfg.exp.train.trials/length(cfg.exp.n_stim);
        pair_perms = cfg.exp.train(i).pair_perms;
    case 'main'
        n_trials   = cfg.exp.n_trials/length(cfg.exp.n_stim);
        pair_perms = cfg.exp.main(i).pair_perms;
end

test_perms = zeros(n_trials/cfg.exp.n_pairs(i),cfg.exp.n_pairs(i));

for nTrial = 1:n_trials/cfg.exp.n_pairs(i)
    
    % generate random sample
    test_perms(nTrial,:) = randperm(cfg.exp.n_pairs(i));
   
end

test_perms = reshape(test_perms, 1, n_trials);
test_perms = test_perms(:,randperm(length(test_perms)));


end