function output = sig_filter(sig,coe)
N = length(coe);
output = zeros(size(sig,1)+N-1,size(sig,2));
for idx = 1:size(sig,2)
    output(:,idx) = conv(sig(:,idx),coe);
end
output = output(N:end,:);
