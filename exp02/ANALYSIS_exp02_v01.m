%% Analysis for Experiment 2

% cfg.path.main_exp = ['C:/Users/' getenv('username') '/ownCloud/PhD/Matlab/Memory-Recall-Task/exp02/raw/main/'];  % 'raw/main_exp/';  % path to save main exp data

ptN = 2
for i = 1:cfg.exp.n_trials
   corr(ptN,i)    = rec{i}.test.RT(1);
   RT(ptN,i)      = rec{i}.test.RT(2);
   conf(ptN,i)    = rec{i}.conf.position;
   conf_RT(ptN,i) = rec{i}.conf.RT;
end
easy = 1:2:47;
hard = 2:2:48;
hold off
close all
[f1,gof1]=fit(RT(1,:)',conf(1,:)','poly1')
[f2,gof2]=fit(RT(2,:)',conf(2,:)','poly1')
scatter(RT(1,easy),conf(1,easy),[],[1 0 0]);
hold on
scatter(RT(1,hard),conf(1,hard),'filled','MarkerFaceColor',[1 0 0]);
scatter(RT(2,easy),conf(2,easy),[],[0 1 0]);
h = scatter(RT(2,hard),conf(2,hard),'filled','MarkerFaceColor',[0 1 0]);
l1 = plot(f1);
l2 = plot(f2);
l2.Color = [0 1 0];
l1.XData = l1.XData(10:270);
l1.YData = l1.YData(10:270);
l2.XData = l2.XData(10:700);
l2.YData = l2.YData(10:700);
legend({'Pt. 1 Easy','Pt. 1 Hard','Pt. 2 Easy', 'Pt. 2 Hard'});
xlabel('Reaction Time (s)');
ylabel('Confidence (%)');
ylim([0 100]);

sum(corr(1:2:end))
sum(corr(2:2:end))

scatter(RT(1:2:end),conf(1:2:end))
scatter(RT(2:2:end),conf(2:2:end))
[R, p] = corrcoef(RT,conf)
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
