%--------------------------------------------------------------------------
%   对信号做iq正交处理
function [output] = iq_process(sig)
disp("输入信号按照列排列")
long = size(sig,1);
N = fix(long/4);
M = rem(long,4);
I(1,:)= ones(1,N+1);
I(2,:)= zeros(1,N+1);
I(3,:)= -1*ones(1,N+1);
I(4,:)= zeros(1,N+1);
Q(1,:)= zeros(1,N+1);
Q(2,:)= ones(1,N+1);
Q(3,:)= zeros(1,N+1);
Q(4,:)= -1*ones(1,N+1);

I = reshape(I,1,4*(N+1));
Q = reshape(Q,1,4*(N+1));
I = I(1:(4*N+M))';
Q = Q(1:(4*N+M))';
output = sig.*I+1j.*sig.*Q;
