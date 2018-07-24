%--------------------------------------------------------------------------
%   20180621
%   数据写入输出txt文档
%--------------------------------------------------------------------------
%   write_data(data_name,data_type,file_name)
%   输入：
%   data_name   数据名称
%   data_type   数据格式
%   file_name   数据文件名
%--------------------------------------------------------------------------
%   example
%   cos_data = round(8191*real(rt.exp_wave(1/5e6,5e6,350e6)));
%   rt.write_data(cos_data,,'%d,\n','a.txt')
%--------------------------------------------------------------------------
function write_data(data_name,data_type,file_name)
[M,~] = size(data_name);
f = fopen(file_name,'w');
for idx = 1:M
            fprintf(f,data_type,data_name(idx,:));
            fprintf(f,'\n');
end
fclose(f);