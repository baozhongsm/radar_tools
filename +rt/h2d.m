%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [dataout] = rt.d2h(datain,N_bit)
%--------------------------------------------------------------------------
%   Description:
%   converse Hex complement to Decimal(ofen use for FPGA test)
%--------------------------------------------------------------------------
%   input:
%           datain                  input data
%           N_bit                   converse digit
%   output:
%           dataout                 output data
%--------------------------------------------------------------------------
%   Examples:   
%   rt.h2d(["0d","3f";"15","22"],5)
%   ans =
%       13    31
%      -11     2
%--------------------------------------------------------------------------
function [dataout] = h2d(datain,N_bit)
dataout = hex2dec(datain);
dataout(dataout>=2^(N_bit-1)) = dataout(dataout>=2^(N_bit-1))-2^N_bit;




    
    