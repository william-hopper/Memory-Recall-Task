function [perseveranceP] = eng_comp(~,P,u_t,~)
%% sigmoid for VBA_simulate
R = u_t(1);   % reward
E = u_t(2);   % effort 

bR = P(1);     % reward weight
bE = P(2);    % effort  weight
b3 = P(3);

if length(P) == 5
    beta = exp(P(5)); % decision temperature
end

presig = R*bR + E*bE + b3;

%% Perform mathematics:
if length(P) == 5
    perseveranceP = VBA_sigmoid(presig*beta);
else
    perseveranceP = VBA_sigmoid(presig);
end