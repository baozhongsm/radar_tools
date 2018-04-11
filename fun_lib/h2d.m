%--------------------------------------------------------------------------
%   16进制　有符号　->10进制
%   20180409
%   刘夏
%   qwe14789cn@gmail.com
%   h_output = d2h(data,N_bit)
%   data    16进制原始数据 string类型
%   N_bit   2进制下的位数
%--------------------------------------------------------------------------
function d = h2d(data,N_bit)
 str_len= rem(N_bit,4);
if str_len~=0
    disp('二进制位数必须为4的倍数');
    return
end
d = hex2dec(data);
d(d>2^(N_bit-1)) = d(d>2^(N_bit-1))-2^N_bit;




    
    