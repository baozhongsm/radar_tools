%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [d] = rt.d2h(datain,N_bit)
%--------------------------------------------------------------------------
%   Description:
%   converse Decimal to Hex complement(ofen use for FPGA test)
%--------------------------------------------------------------------------
%   input:
%           datain                  input data
%           N_bit                   converse digit
%   output:
%           dataout                 output data
%--------------------------------------------------------------------------
%   Examples:   
%   rt.d2h(13,5)
%   ans = 
%       "D"
%--------------------------------------------------------------------------
function dataout = d2h(datain,N_bit)
[X,Y,Z] = size(datain);
datain(datain<0) = datain(datain<0)+2^N_bit;
h = dec2hex(datain);
temp = string([]);
for index = 1:X*Y*Z
    temp(index)= string(h(index,:));
end
dataout = reshape(temp,[X Y Z]);


    
    