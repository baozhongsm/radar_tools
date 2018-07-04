%--------------------------------------------------------------------------
%   20180601
%   刘夏
%   信号频谱自动化分析工具
%--------------------------------------------------------------------------
%   输入:
%   sig     信号
%   fs      采样速率
%   AD_len  AD位数
%   N_waves 除主频率外谐波数量
%   N_sep   主频率+谐波隔离点数              默认10
%   Nfft    fft点数                         默认10
%   rho     频率分辨率0表示最高              默认10
%	输出：
%   F       频率轴
%   P       功率数据
%--------------------------------------------------------------------------
%   example
%--------------------------------------------------------------------------
%   rt.AD_analyzer(sig,fs,AD_len,N_waves)
%   rt.AD_analyzer(sig,fs,AD_len,N_waves,N_sep)
%   rt.AD_analyzer(sig,fs,AD_len,N_waves,N_sep,Nfft)
%   rt.AD_analyzer(sig,fs,AD_len,N_waves,N_sep,Nfft,rho)
%--------------------------------------------------------------------------
function [F,P] = AD_analyzer(sig,fs,AD_len,N_waves,N_sep,Nfft,rho)
disp('要求:输入信号必须满载,满载输入时的有效位数最高')
if nargin <=3
    disp('输入变量至少需要：信号，采样率，AD长度，谐波数量');
    return
elseif nargin <=4
    N_sep = 10;
    Nfft  = 1024;
    rho   = 10;
elseif nargin <=5
	Nfft  = 1024;
    rho   = 10; 
elseif nargin <=6
	rho   = 10;
end

[P,F] = pwelch(sig,kaiser(length(sig),rho),[],Nfft,fs);                     %获得频谱图
db = pow2db(P);                                                             %换算成db

maxloc = find(db==max(db));                                                 %信号最大频率坐标
[~,loc] = findpeaks(db,'MinPeakDistance',(2*Nfft/100));                     %峰值频率坐标

N = round(N_waves/2);                                                       %谐波数量
mid = find(loc ==maxloc);                                                   %中心信号
X = loc(mid-N:mid+N);                                                       %谐波+主频坐标
XX = [X-N_sep X+N_sep];                                                     %谐波坐标挖去范围

NDR = 0.5 * mean(P(1:(loc(mid)-N_sep))) + ...                               %除去主信号后所有平均功率
      0.5 * mean(P((loc(mid)+N_sep):end));
NDR = pow2db(NDR);

for idx = 1:size(XX,1)
    Y(idx,:) =  XX(idx,1):XX(idx,2);
end
Y = Y';                                                                     %计算谐波坐标尺度
n_loc=Y(:);                                                                 %挖去坐标所有点
n_loc = [(1:(loc(1)+N_sep))';n_loc;((loc(end)-N_sep):length(P))'];                          %添加直流挖去范围

%--------------------------------------------------------------------------
%   排除挖去坐标获得低噪坐标
%--------------------------------------------------------------------------
x = 1:length(F);
for idx = 1:length(n_loc)
    x(x==n_loc(idx))=[];
end

%--------------------------------------------------------------------------
%   可视化
%--------------------------------------------------------------------------
figure;
plot(F/1e6,db,'LineWidth',1.5);grid on;hold on;                             %原始信号
plot(F(n_loc)/1e6,db(n_loc),'g-','LineWidth',1.2);                          %谐波,直流筛选
plot(F(maxloc-N_sep:maxloc+N_sep)/1e6,db(maxloc-N_sep:maxloc+N_sep),...     %信号筛选
    'r-','LineWidth',1.2);
title('AD频谱分析')
legend('频谱分析','谐波,直流筛选','信号筛选');xlabel('频率 MHz');ylabel('幅度 dB')
hold off

%--------------------------------------------------------------------------
%   输出部分
%--------------------------------------------------------------------------
SNDR = db(maxloc) - NDR;
SNR = db(maxloc)- pow2db(mean(P(x)));
X(X==maxloc)=[];                                                            %剩下全是谐波的频率坐标
ang = rad2deg(angle(max(fft(sig))));
%--------------------------------------------------------------------------
fprintf('-------------------------------------------------------------\n');
fprintf("信号频率 -> %1.2f Mhz\n",F(maxloc)/1e6);
fprintf('-------------------------------------------------------------\n');
for idx = 1:length(X)
    fprintf("谐波频率 -> %1.2f Mhz\n",F(X(idx))/1e6);
end
fprintf('-------------------------------------------------------------\n');
fprintf('峰值角度    -> %1.2f°\n',ang);
fprintf("理想信噪比  -> %1.2f dB\n",6.02*AD_len + 1.76);
fprintf("实际信噪比  -> %1.2f dB\n",SNR);
fprintf("信噪失真比  -> %1.2f dB\n",SNDR);
fprintf("理想有效位  -> %1.2f \n",AD_len);
fprintf("实际有效位  -> %1.2f \n",(SNDR-1.76)/6.02);
fprintf('-------------------------------------------------------------\n');