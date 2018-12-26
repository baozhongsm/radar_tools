%--------------------------------------------------------------------------
%   keystone算法注释：刘夏 20181122
%   参考文献:The Keystone Transformation for Correcting Range Migration
%   in Range-Doppler Processing
%--------------------------------------------------------------------------
% keystone
%
% Demo of keystone formatting for correcting range-Doppler
% measurements for range migration.
%
% This code closely follows the equations in the tech memo "The Keystone
% Transformation for Correcting Range Migration in Range-Doppler
% Processing" by Mark A. Richards, Mar. 2014, available at www.radarsp.com.
%
% Mark Richards
%
% March 2014
%--------------------------------------------------------------------------
clear;clc
close all

%--------------------------------------------------------------------------
%   参数设置
%--------------------------------------------------------------------------
c = 3e8;                                                                    %光速
L = 128;                                                                    %快时间采样点数
M = 101;                                                                    %慢时间采样点数

K_L = 2^(nextpow2(128)+1);                                                  %快时间FFT点数
K_M = 2^(nextpow2(512)+1);                                                  %慢时间FFT点数

Lref = 100;                                                                 %仿真目标距离单元 设置目标在距离单元居中round(L/2)
F0 = 1e9;                                                                   %射频信号
B = 200e6;                                                                  %信号波形带宽
v = 1000;                                                                    %目标速度

Fsft = 2.3*B;                                                               %采样速率为2.3倍信号带宽,快时间频带宽度
PRF = 10e3;                                                                 %脉冲重复频率

Nsinc = 11;                                                                 %sinc函数点数/阶数

%--------------------------------------------------------------------------
%   参数计算
%--------------------------------------------------------------------------
lambda = c/F0;

m_end = (M-1)/2;
ms = (-m_end:m_end);                                                        %构造慢时间坐标系

Fd = 2*v/lambda;                                                            %多普勒频率
Tft = 1/Fsft;                                                               %快时间采样间隔
dr = c*Tft/2;                                                               %距离门长度
Tst = 1/PRF;                                                                %慢时间采样间隔

Dfd = 1/M;                                                                  %归一化瑞丽多普勒分辨率
Drb = (1/B)/Tft;                                                            %距离单元下瑞丽快时间分辨率

%--------------------------------------------------------------------------
%   不知道这是啥条件，看不懂
%--------------------------------------------------------------------------
if (PRF < abs(Fd)/2)
    fprintf('\n警告: PRF < Fd/2. PRF = %g, Fd = %g.\n',PRF,Fd)
end
%--------------------------------------------------------------------------
%   计算一个CPI中的跨距离单元数据
%--------------------------------------------------------------------------
RM = v*Tst/dr;                                                              %一个PRT下目标距离走动单元
RMtot = M*RM;                                                               %一个CPI下目标距离走动单元

fprintf('\n总共距离走动 = %g 米 = %g 距离单元.\n',RMtot*dr,RMtot);

%--------------------------------------------------------------------------
%   走动范围判决，目标别跑太快了，跑出距离维区域
%--------------------------------------------------------------------------
if ( (floor(Lref-RMtot/2) < 0) || (ceil(Lref+RMtot/2) > L-1) )
    fprintf(['\n警告: 目标走出距离范围', ...
    'RMtot = %g 距离单元, Lref = %g, L = %g 距离单元.\n'],RMtot,Lref,L)
end

%--------------------------------------------------------------------------
%   计算归一化多普勒频率
%--------------------------------------------------------------------------
Fd = Fd*Tst;                                                                %归一化多普勒频率
fdn = mod(Fd + 0.5,1) - 0.5;                                                %取余 缩放到[-0.5 0.5]范围
disp('多普勒模糊数')
amb_num = round(Fd - fdn)                                                   %多普勒模糊数
amb_num = 0
%--------------------------------------------------------------------------
%   距离 速度分辨率尺度范围
%--------------------------------------------------------------------------
L1 = Lref - Drb;
L2 = Lref + Drb;
fd1 = fdn - Dfd;
fd2 = fdn + Dfd;

%--------------------------------------------------------------------------
%   模拟回波信号，构造合成数据，首先计算脉冲相位，然后构造回波存储矩阵，循环计算
%   脉压后数据假定为sinc函数形态,零点间距1/B秒，相位移动-(4*pi*F0/c)*R，
%   R = Rref - v*Tst*m 并且 m 表示脉冲数。不考虑振幅衰减。
%--------------------------------------------------------------------------
del_phi = -4*pi*(F0/c)*v*Tst;                                               %回波相位变化量
y = zeros(L,M);                                                             %回波矩阵

%--------------------------------------------------------------------------
%   回波仿真
%--------------------------------------------------------------------------
for m = 1:M                                                     
    mm = ms(m);                                                             %计算慢时间坐标
    y(:,m) = exp(-1i*del_phi*mm)*sinc( B*Tft*((0:L-1)-Lref+v*Tst*mm/dr) );  %相位项+距离项
end

%--------------------------------------------------------------------------
%   MTD
%--------------------------------------------------------------------------
Y_rD = fft(y,K_M,2);Y_rD = fftshift(Y_rD,2);
Y_rD_dB = db(Y_rD);
Y_rD_dB = Y_rD_dB - max(Y_rD_dB(:));
fD = (-K_M/2:K_M/2-1)/K_M;

%--------------------------------------------------------------------------
%   可视化
%--------------------------------------------------------------------------
f1 = figure(1);f1.Position = [273 501 1215 448];
subplot(121)
imagesc(ms,0:L-1,abs(y))
grid on
xlabel('脉冲数');ylabel('距离单元');title('原始 快时间/慢时间数据')

subplot(122)
fD = (-K_M/2:K_M/2-1)/K_M;
imagesc(fD,0:L-1,Y_rD_dB)

% %--------------------------------------------------------------------------
% %   绘制距离 速度分辨率单元
% %--------------------------------------------------------------------------
% line([fd1 fd1 fd2 fd2 fd1],[L1 L2 L2 L1 L1],'Color','k','LineWidth',1.5);
% disp(['figure2:一个CPI距离走动 = ',num2str(RMtot),...
% ' ;归一化多普勒 = ',num2str(fdn),' cyc/samp'])
% title('MTD');xlabel('归一化多普勒');ylabel('距离单元');colorbar

%%
%--------------------------------------------------------------------------
%   假设我们速度已知,那么距离项的补偿可以通过频域的相位来实现，因此将回波信号
%   变换到频率域，然后补偿相位项，然后反变换得到的原始数据来补偿距离
%--------------------------------------------------------------------------
Y_Rd = fftshift(fft(y,K_L,1),1);
Fl = (-K_L/2:K_L/2-1)/K_L*Fsft;                                             %快时间频域分布范围

%--------------------------------------------------------------------------
%   幅相特性可视化
%--------------------------------------------------------------------------
% f2 = figure(2);f2.Position = [272 330 1214 420];
% subplot(121)
% imagesc(ms,F0+Fl,abs(Y_Rd))
% xlabel('慢时间')
% ylabel('快时间频域')
% title('快时间频域后幅度图')
% colorbar
% subplot(122)
% imagesc(ms,F0+Fl,angle(Y_Rd))
% xlabel('慢时间')
% ylabel('快时间频域')
% title('快时间频域后相位图(未解缠绕)')
% colorbar

%--------------------------------------------------------------------------
%   现在对已知的速度对每个脉冲进行插值补偿
%--------------------------------------------------------------------------
yc = zeros(size(y));                                                        %新的快慢时间存储器
wl = 2*pi*(-K_L/2:K_L/2-1)'/K_L;                                            %这就是旋转因子 啊啊啊啊啊
wl = fftshift(wl);                                                          %这里shift一下是为了对应matlab fft数据
%--------------------------------------------------------------------------
%   频域相位补偿-时域周期循环 校正信号 
%--------------------------------------------------------------------------
for m = 1:M
    mm = ms(m);                                                             %脉冲序号
    Lm = v*Tst*mm/dr;                                                       %距离单元走动序号,也就是平移补偿点数
    Y_shift = fft(y(:,m),K_L).*exp(-1i*wl*Lm);                              %每次回波数据补偿相位多普勒
    y_shift_temp = ifft(Y_shift);                                           %得到回波数据
    y_shift(:,m) = y_shift_temp(1:L);                                       %取采样点长度数据
end

%--------------------------------------------------------------------------
%   可视化
%--------------------------------------------------------------------------
% f3 = figure(3);f3.Position = [454 378 1203 413];
% subplot(121)
% imagesc(ms,0:L-1,abs(y_shift))
% grid
% xlabel('脉冲数')
% ylabel('距离单元')
% title('补偿距离走动后的雷达回波数据')
% Y_shift = fft(y_shift,K_M,2);
% Y_shift = fftshift(Y_shift,2);
% Y_shift_dB = db(abs(Y_shift),'voltage');
% Y_shift_dB = Y_shift_dB - max(Y_shift_dB(:)); 
% Y_shift_dB(:) = max(-40,Y_shift_dB(:));
% colorbar
% subplot(122)
% imagesc(fD,0:L-1,Y_shift_dB)
% line([fd1 fd1 fd2 fd2 fd1],[L1 L2 L2 L1 L1],'Color','w','LineWidth',2)      %分辨窗
% box
% xlabel('归一化多普勒')
% ylabel('距离单元')
% title('距离补偿后的距离多普勒平面')
% colorbar

%--------------------------------------------------------------------------
%   补偿后幅相特性可视化
%--------------------------------------------------------------------------
Y_Rd_shift = fftshift(fft(y_shift,K_L,1),1);

%--------------------------------------------------------------------------
%   可视化
%--------------------------------------------------------------------------
% f4 = figure(4);f4.Position = [456 508 1199 420];
% subplot(121)
% imagesc(ms,F0+Fl,abs(Y_Rd_shift))
% xlabel('慢世间')
% ylabel('快时间频率')
% title('快时间频域后幅度图')
% colorbar
% subplot(1,2,2)
% imagesc(ms,F0+Fl,angle(Y_Rd_shift))
% xlabel('慢时间')
% ylabel('快时间频域')
% title('快时间频域后相位图(解缠绕)')
% colorbar
%%
%--------------------------------------------------------------------------
%   keystone算法
%--------------------------------------------------------------------------
%   重新开始上述的算法过程，从Y_Rd数据开始(距离走动的频域数据,shift后)，快时间
%   是频谱图+shift,慢时间不做处理。对每一个快时间频域数据，采用sinc函数，插值
%--------------------------------------------------------------------------
% Now start over and correct by keystoning. Begin with Y_Rd, i.e. data
% DFT'ed in fast time but not in slow time. For each fast-time frequency
% bin, compute a new, interpolated slow-time sequence. Use the existing
% sinc_interp function for bandlimited, Hamming-weighted interpolation to
% do the work.
%--------------------------------------------------------------------------
Y_Rd_key = zeros(size(Y_Rd));
for k = 1:K_L
    %----------------------------------------------------------------------
%     [y_temp,mm_i] = sinc_interp(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms,Nsinc,1);
    %----------------------------------------------------------------------
%   重新写插值函数，修改后用y_temp = Y_Rd(k,:)*sinc_interp_mat矩阵相乘实现
%   keystone算法
%--------------------------------------------------------------------------
    [y_temp,sinc_interp_mat] = sinc_in(Y_Rd(k,:),ms,(F0/(F0+Fl(k)))*ms);
    % y_temp = interp1(ms,Y_Rd(k,:),(F0/(F0+Fl(k)))*ms,'spline');
    % Mi will always be odd the way I'm setting up the problem. Also, Mi <= M.
    Mi = length(y_temp);
    dM = M - Mi; % dM will be even so long as M and Mi are odd
%     Y_Rd_key(k,1+dM/2:1+dM/2+Mi-1) = y_temp; % center the interpolated data in slow
    Y_Rd_key(k,:) = y_temp; % center the interpolated data in slow
%     imagesc(db(Y_Rd_key));drawnow;
end

%--------------------------------------------------------------------------
%   keystone算法的缺陷，多普勒模糊的影响
%--------------------------------------------------------------------------
%   现在考虑多普勒模糊造成的影响，以下代码考虑第一目标的多普勒模糊数，所以如果
%   在多目标情况夏不同的目标具有不同的模糊数，就会校正失败。因此加入模糊数项
%   对齐进行补偿，扩大多普勒范围
% Now correct the modified spectrum for the ambiguity number of the
% Doppler. This code uses the ambiguity number of the first target. So if
% the other targets have a different ambiguity number it won't be correct
% for them. The first version of the correction corresponds to the Li et al
% paper and is consistent with my memo. The second (commented out)
% corresponds to the Perry et al paper and can be obtained from the first
% using a binomial expansion approximation to (F0/(F0+Fl)). Either one
% works if done either after the keystone correction, as is done here, or
% before.
%--------------------------------------------------------------------------
for mp = 1:M
    for k = 1:K_L
        mmp = ms(mp); % counts from -(M-1/2) to +(M-1)/2
        Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(1i*2*pi*amb_num(1)*mmp*(F0/(F0+Fl(k))));
% Y_Rd_key(k,mp) = Y_Rd_key(k,mp)*exp(-1i*2*pi*amb_num(1)*mmp*(Fl(k)/F0));
    end
end
% Now IDFT in fast-time and DFT in slow time to get range-Doppler matrix
y_temp_key = ifft( ifftshift(Y_Rd_key,1),K_L,1 );
y_rd_key = y_temp_key(1:L,:);
Y_rD_key = fftshift( fft(y_rd_key,K_M,2),2 );
Y_rD_key_dB = db(abs(Y_rD_key),'voltage');
Y_rD_key_dB = Y_rD_key_dB - max(Y_rD_key_dB(:)); % normalize to 0 dB max
Y_rD_key_dB(:) = max(-40,Y_rD_key_dB(:)); % limit to 40 dB range
figure
imagesc(ms,0:L-1,abs(y_rd_key))
grid

xlabel('慢时间')
ylabel('快时间')
title('Keystone变换后的快慢时间数据')
% figure
% mesh(fD,0:L-1,Y_rD_key_dB)
% xlabel('normalized Doppler')
% ylabel('fast time')
% title('Keystoned Range-Doppler Matrix')

figure
imagesc(fD,0:L-1,Y_rD_key_dB)
% hline(Lref,':w'); vline(fdn,':w') % mark the correct spectrum center
xlabel('归一化多普勒')
ylabel('距离单元')
title('Keystone变换后的MTD平面')
shg
colorbar
figure
subplot(1,2,1)
imagesc(ms,F0+Fl,abs(Y_Rd_key))
xlabel('慢时间')
ylabel('快时间频域')
title('插值后幅度')
colorbar
subplot(1,2,2)
imagesc(ms,F0+Fl,angle(Y_Rd_key))
xlabel('慢时间')
ylabel('快时间频域')
title('插值后相位')
colorbar