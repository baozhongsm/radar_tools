%--------------------------------------------------------------------------
%   将信号重新修正为需要的形态
%--------------------------------------------------------------------------
%   function dataout = data_reshape(datain,data_size)
%   输入:
%   datain 原始信号
%   data_size MTD形态
%--------------------------------------------------------------------------
%   example
%   data_size = [2640 1024];
%   dataout = data_reshape(datain,data_size)
%--------------------------------------------------------------------------
function dataout = data_reshape(datain,data_size)
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
