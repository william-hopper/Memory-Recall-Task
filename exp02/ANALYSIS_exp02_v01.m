%% Analysis for Experiment 2

% cfg.path.main_exp = ['C:/Users/' getenv('username') '/ownCloud/PhD/Matlab/Memory-Recall-Task/exp02/raw/main/'];  % 'raw/main_exp/';  % path to save main exp data


for i = 1:cfg.exp.n_trials
   corr(i)    = rec{i}.test.RT(1);
   RT(i)      = rec{i}.test.RT(2);
   conf(i)    = rec{i}.conf.position;
   conf_RT(i) = rec{i}.conf.RT;
end

sum(corr(1:2:end))
sum(corr(2:2:end))

scatter(RT(1:2:end),conf(1:2:end))
scatter(RT(2:2:end),conf(2:2:end))
corrcoef(RT,conf)
corrcoef(RT(1:2:end),conf(1:2:end))
corrcoef(RT(2:2:end),conf(2:2:end))

stats(1,1) = mean(RT(1:2:end));
stats(1,2) = mean(conf(1:2:end));
stats(1,3) = sum(corr(1:2:end));
stats(2,1) = mean(RT(2:2:end));
stats(2,2) = mean(conf(2:2:end));
stats(2,3) = sum(corr(2:2:end))

ttest2(RT(1:2:end),RT(2:2:end))
ttest2(conf(1:2:end),conf(2:2:end))
ttest2(corr(1:2:end),corr(2:2:end))
