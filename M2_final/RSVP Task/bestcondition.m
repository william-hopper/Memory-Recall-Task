function [maxdiffTrials] = bestcondition(n_offers,n_tr)

checkdiff = NaN(100000,1);

trials = NaN(100000,n_offers);

 

for i = 1:100000
    trials (i,:)= permtrials(n_tr);

%     if checkframe (trials(i,:)) >= 2

        checkdiff (i) = checkperm(trials(i,:));

%     end 

end

 

maxdiff = max(checkdiff);

 

ind = find(checkdiff==(maxdiff));

maxdiffTrials = trials(ind(1),:);