%--------------------------------------------------------------------------
%   补码
%   10进制－〉2进制
%   20180419
%   刘夏
%   qwe14789cn@gmail.com
%--------------------------------------------------------------------------
%   h_output = d2b(data,N_bit)
%   data    10进制原始数据
%   N_bit   2进制下的位数
%--------------------------------------------------------------------------
function h_output = d2b(data,N_bit)
[X,Y,Z] = size(data);
data(data < 0) = data(data < 0)+2^N_bit;
h = dec2bin(data);
for index = 1:X*Y*Z
    temp(index)= string(h(index,:));
end
h_output = reshape(temp,[X Y Z]);


    
    