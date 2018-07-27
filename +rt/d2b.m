%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [dataout] = rt.d2b(datain,N_bit)
%--------------------------------------------------------------------------
%   Description:
%   converse Decimal to Binary complement(ofen use for FPGA test)
%--------------------------------------------------------------------------
%   input:
%           datain                  inpput data
%           N_bit                   converse digit
%   output:
%           dataout                 output data
%--------------------------------------------------------------------------
%   Examples:   
%   rt.d2b(13,5)
%   ans =
%       "1101"
%--------------------------------------------------------------------------
function dataout = d2b(datain,N_bit)
[X,Y,Z] = size(datain);
datain(datain < 0) = datain(datain < 0)+2^N_bit;
h = dec2bin(datain);
for index = 1:X*Y*Z
    temp(index)= string(h(index,:));
end
dataout = reshape(temp,[X Y Z]);


    
    