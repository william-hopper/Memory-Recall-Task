function [pair_perms] = generate_pair_perms_v02(cfg, train_or_main, i)
%
% This function generates nTrial sets of nStim/2 pairs of stimuli
%
% Author:   William Hopper
% Original: 15/01/2020

switch train_or_main
    case 'training'
        n_trials = cfg.exp.train.trials/length(cfg.exp.n_stim);
    case 'main'
        n_trials = cfg.exp.n_trials/length(cfg.exp.n_stim);
end

% pre-allocate
pair_perms = zeros(2, cfg.exp.n_pairs(i), n_trials);

switch cfg.exp.n_stim(i)
    case 12
        a = [1 3 5 7 9  11;...
             2 4 6 8 10 12];
    case 16
        a = [1 3 5 7 9  11 13 15;...
             2 4 6 8 10 12 14 16];
end

% generate pairs for nTrials
for nTrial = 1:n_trials
    
    switch cfg.exp.random
        case 0
            pair_perms(:,:,nTrial) = a;
            
        case 1
            
            % pair_perms(1,1,nTrial) + pair_perms(2,1,nTrial) = first pair
            % pair_perms(1,2,nTrial) + pair_perms(2,2,nTrial) = second pair etc..
            %     pair_perms(:,:,nTrial) = reshape(randperm(cfg.exp.n_stim), 2, cfg.exp.n_pairs);
            
            pair_perms(:,:,nTrial) = a(:,randperm(cfg.exp.n_pairs(i)));
    end
    
end

end