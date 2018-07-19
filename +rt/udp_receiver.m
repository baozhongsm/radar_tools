%--------------------------------------------------------------------------
%   udp接收工具
%--------------------------------------------------------------------------
%   接收udp传输数据
%--------------------------------------------------------------------------
%   example
%   udp_receiver(8081)
%--------------------------------------------------------------------------
function [bytesReceived] = udp_receiver(portnumber)
persistent udpRx
if isempty(udpRx)
    udpRx = dsp.UDPReceiver('MessageDataType','uint8'); 
end 
udpRx.LocalIPPort = portnumber;
dataReceived = [];
while isempty(dataReceived)
    dataReceived = udpRx();
end
