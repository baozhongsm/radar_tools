function [data_out,sinc_interp_matrix] = sinc_in(data_in,x_in,x_new)
%--------------------------------------------------------------------------
%   20181127 刘夏
%   sinc插值函数重写，去掉了各种乱七八糟的条件，实在是看不懂 直接抓插值部分
%   另外,data_in按照行排列,插值后的数据为data_in * sinc_interp_matrix
%--------------------------------------------------------------------------
sinc_interp_matrix = zeros(length(x_in),length(x_new));
% delta1 = x_in(2)-x_in(1);
delta2 = x_new(2)-x_new(1);

delta = delta2;                                                             %按照插值间距设计滤波器带宽 B = 1/delta

%--------------------------------------------------------------------------
%   核心函数  sinc((x-x0)/delta) 带宽是1/delta x0需要的点数据
%--------------------------------------------------------------------------
for idx = 1:length(data_in)
    data_out(idx) = sum(data_in.*sinc((x_in-x_new(idx))./delta));
    sinc_interp_matrix(:,idx) = sinc((x_in-x_new(idx))./delta);
end
