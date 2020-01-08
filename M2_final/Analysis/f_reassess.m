function  [fx] = f_reassess(x,P,u,in)
% reassessment 
% IN: 
%	- x: reassessment resource
%	- P(1): gamma = xt weight
%   - P(2): lambda(1) = momentary effort weight
%   - P(3): lambda(2) = effort change weight
%	- u(1): momentary effort
%   - u(2): effort change
%	- in: [useless]
% OUT:
%   - fx: updated reassessment resource

fx = (1-P(1))*x + u(1)*P(2) + u(2)*P(3);

end

% dfdx = dfdx';
% dfdP = dfdP';