function[d]  = checkperm (V)

D = NaN (6,1);

for i = 1:6

    ind = find (V == i); % indices in that vector where the Vector equals i

    di = diff(ind);

    D(i) = min(di);

end

 

d = min(D);

%d = mean (D);

end