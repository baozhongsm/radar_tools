function y = sinc_interp(x,u)   %x 输入信号，u插值点数坐标
m = 0:length(x)-1;

for idx = 1:length(u)
    y(idx) = sum(x.*sinc(m-u(idx))); %sinc函数对称 这里无所谓
end
