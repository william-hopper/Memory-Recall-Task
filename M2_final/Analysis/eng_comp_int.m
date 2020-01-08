function [perseveranceP] = eng_comp_int(~,P,u_t,~)
%% sigmoid for VBA_simulate
R = u_t(1);   % reward
E = u_t(2);   % effort 
I = u_t(3); % interaction

bR = P(1);     % reward weight
bE = P(2);     % effort weight
b3 = P(3);     % constant
bI = P(4);     % interaction


presig = R*bR + E*bE + b3 + bI*I;

%% Perform mathematics:
perseveranceP = VBA_sigmoid(presig);