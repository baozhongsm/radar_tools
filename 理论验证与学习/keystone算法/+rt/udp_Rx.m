function Received = udp_Rx(port,package_size)
udpRx = dsp.UDPReceiver('MessageDataType','uint8'); 
udpRx.LocalIPPort = port;
udpRx.ReceiveBufferSize = 65536;
udpRx.MaximumMessageLength = package_size(1);
TOTAL = package_size(2);
Rx = [];
Received = uint8(zeros(package_size(1)));
idx = 1;
disp('waiting...')
while TOTAL
    Rx = udpRx();
    if ~isempty(Rx)
        Received(:,package_size(2)-TOTAL+1) = Rx;
        TOTAL = TOTAL -1;
    end
end
disp('finished')
Received = double(Received);
