function  [gx] = g_reassess(x,P,u,in)
% reassessment 
% IN: 
%	- x: reassessment resource
%   - P(1): beta(1) = reward weight
%   - P(2): beta(2) = effort left weight
%   - P(3): beta(3) = beta constant
%   - P(4): omega 0 = base rate
%	- u(1): reward
%   - u(2): effort left
%   - u(3): effort level
% OUT:
%   - gx: probability of sustaining


gx = 1 + (VBA_sigmoid(x+P(4)))*(VBA_sigmoid((u(3)*P(1)) + (u(4)*u(5)*P(2)) +P(3)) - 1);

end

% dfdx = dfdx';
% dfdP = dfdP';