%--------------------------------------------------------------------------
%   rt toolbox
%   author:qwe14789cn@gmail.com
%   https://github.com/qwe14789cn/radar_tools
%--------------------------------------------------------------------------
%   [dataout] = rt.data_reshape(datain,data_size)
%--------------------------------------------------------------------------
%   Description:
%   along the Column cut the data to the set size
%--------------------------------------------------------------------------
%   input:
%           datain                  input data
%           data_size               reshape size
%   output:
%           dataout                 output data
%--------------------------------------------------------------------------
%   Examples:
%   a = [1 2 3 4 5 6 7 8 9 10];
%   rt.data_reshape(a,2)
%   ans =
%     1     3     5     7     9
%     2     4     6     8    10
%   rt.data_reshape(a,[2 2])
%   ans(:,:,1) =
%     1     3
%     2     4
%   ans(:,:,2) =
%     5     7
%     6     8
%--------------------------------------------------------------------------
function [dataout] = data_reshape(datain,data_size)
dim = length(size(datain));
if dim >= 3
    disp('输入信号维度必须为2维');
    return
end

L = size(datain)==1;
if L(1)==0 && L(2)==1
    disp('列排列 -> 数据处理')
elseif L(1)==1 && L(2)==0
    disp('行排列 -> 信号转置 -> 数据处理')
    datain = datain.';
else
    disp('请保证输入数据为一维数组')
    return
end
if length(data_size)==2
    level = floor(size(datain,1)/(data_size(1)*data_size(2)));              %先计算可以得到多少个CPI数量
    datain = datain(1:data_size(1)*data_size(2)*level,:);                   %重新切割数据
    dataout = reshape(datain,data_size(1),data_size(2),level);              %重新修改形状
    
elseif length(data_size)==1
    level = floor(size(datain,1)/(data_size(1)));                           %先计算可以得到多少个CPI数量
    datain = datain(1:data_size(1)*level,:);                                %重新切割数据
    dataout = reshape(datain,data_size(1),level);                           %重新修改形状
end
