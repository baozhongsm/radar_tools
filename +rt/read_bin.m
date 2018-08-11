function [output] = read_bin(file_name,file_type)
f = fopen(file_name,'r');
output = fread(f,file_type);
fclose(f);