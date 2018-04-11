%--------------------------------------------------------------------------
%   10进制  有符号  ->16进制
%   20180409
%   刘夏
%   qwe14789cn@gmail.com
%   h_output = d2h(data,N_bit)
%   data    10进制原始数据
%   N_bit   2进制下的位数
%--------------------------------------------------------------------------
function h_output = d2h(data,N_bit)
 str_len= rem(N_bit,4);
if str_len~=0
    disp('二进制位数必须为4的倍数');
    return
end
[X,Y,Z] = size(data);
data(data<0) = data(data<0)+2^N_bit;
h = dec2hex(data);
for index = 1:X*Y*Z
    temp(index)= string(h(index,:));
end
h_output = reshape(temp,[X Y Z]);


    
    