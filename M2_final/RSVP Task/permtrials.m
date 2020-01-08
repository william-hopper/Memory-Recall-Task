function [C] = permtrials(n_tr)

V = [1:n_tr];
c = [];
if n_tr == 6
    L = 8;
else
    L = 6;
end
for i = 1:L
    
    R1 = V(randperm(n_tr));
    
    c = [c R1];
end

C = c;