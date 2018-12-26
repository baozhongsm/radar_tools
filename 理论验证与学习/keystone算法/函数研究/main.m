clear;clc;
load data.mat
%--------------------------------------------------------------------------
%   Y_Rd 回波数据  F(ft)+st
%   ms 脉冲数坐标点
%   F0射频波长
%   Fl带宽的穷举
%   Nsinc sinc函数阶数 或者点数
%   B = 200e6;                                                              %信号波形带宽
%   Fsft = 2.3*B;                                                           %采样速率为2.3倍信号带宽
%   Fl = (-K_L/2:K_L/2-1)/K_L*Fsft;
M = 101;                                                                    %慢时间采样点数
K_L = 2^(nextpow2(128)+1);                                                  %快时间FFT点数
%--------------------------------------------------------------------------

% k = 1;

% [A] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
%--------------------------------------------------------------------------
%   计算归一化多普勒频率
%--------------------------------------------------------------------------
c = 3e8;
L = 128;                                                                    %快时间采样点数
K_M = 2^(nextpow2(512)+1);                                                  %慢时间FFT点数
F0 = 1e9;                                                                   %射频信号
lambda = c/F0;
v = 400;                                                                    %目标速度
Fd = 2*v/lambda;                                                            %多普勒频率
PRF = 10e3;                                                                 %脉冲重复频率
Tst = 1/PRF;                                                                %慢时间采样间隔
Fd = Fd*Tst;                                                                %归一化多普勒频率
fdn = mod(Fd + 0.5,1) - 0.5;                                                %取余 缩放到[-0.5 0.5]范围
amb_num = round(Fd - fdn);                                                  %多普勒模糊点数


for k = 1:K_L
    [y_temp,mm_i] = sinc_interp(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms,Nsinc,1);
    plot(ms,zeros(length(ms),1),'o','LineWidth',1.5);hold on
    plot((F0/(F0+Fl(k)))*ms,ones(length(ms),1),'o','LineWidth',1.5);
    plot(mm_i,1*ones(length(mm_i),1),'o','LineWidth',1.5);
    hold off;
    legend('原始范围','插值范围','最终范围')
    axis([-70 70 -1 3])
%     [y_temp] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
    % y_temp = interp1(ms,Y_Rd(k,:),(F0/(F0+Fl(k)))*ms,'spline');
    % Mi will always be odd the way I'm setting up the problem. Also, Mi <= M.
    Mi = length(y_temp);
    dM = M - Mi; % dM will be even so long as M and Mi are odd
    Y_Rd_key(k,1+dM/2:1+dM/2+Mi-1) = y_temp; % center the interpolated data in slow
%     imagesc(db(Y_Rd_key))
%     drawnow
end

for mp = 1:M
    for k = 1:K_L
        mmp = ms(mp); % counts from -(M-1/2) to +(M-1)/2
        Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(1i*2*pi*amb_num(1)*mmp*(F0/(F0+Fl(k))));
% Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(-1i*2*pi*amb_num(1)*mmp*(Fl(k)/F0));
    end
end

y_temp_key = ifft( ifftshift(Y_Rd_key,1),K_L,1 );
y_rd_key = y_temp_key(1:L,:);
Y_rD_key = fftshift( fft(y_rd_key,K_M,2),2 );
Y_rD_key_dB = db(abs(Y_rD_key),'voltage');
Y_rD_key_dB = Y_rD_key_dB - max(Y_rD_key_dB(:)); % normalize to 0 dB max
Y_rD_key_dB(:) = max(-40,Y_rD_key_dB(:)); % limit to 40 dB range
figure
imagesc(ms,0:L-1,abs(y_rd_key))
grid
colormap(flipud(gray))
xlabel('slow-time')
ylabel('fast time')
title('Keystoned Fast-time/Slow-time Data Pattern')