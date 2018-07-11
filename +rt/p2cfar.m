%--------------------------------------------------------------------------
%   奈曼皮尔逊检测器
%--------------------------------------------------------------------------
%   输入:
%   datain      数据 列表示距离维
%   pfa         虚警概率
%   train_N     训练单元点数,左右两边总和
%   guard_N     守护单元点数,左右两边总和
%   输出:
%   detected    判决平面
%   th          判决阈值
%--------------------------------------------------------------------------
%   p2cfar形态
%   □□□□□■■◎■■□□□□□
%   □   训练单元
%   ■   守护单元
%   ◎   判决检测
%--------------------------------------------------------------------------
%   example
%   [detected,th] = p2cfar(datain,pfa,train_N,guard_N)
%--------------------------------------------------------------------------
function [detected,th] = p2cfar(datain,pfa,train_N,guard_N)
cfar = phased.CFARDetector('NumTrainingCells',train_N,'NumGuardCells',guard_N);
cfar.ProbabilityFalseAlarm = pfa;
cfar.ThresholdOutputPort = true;
cfar.ThresholdFactor = 'Auto';
[detected,th] = cfar(datain,1:size(datain,1));
