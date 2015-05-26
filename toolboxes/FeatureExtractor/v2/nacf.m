function [e0,nccf] = nacf(frame)

%Take the autocorrelation to extract frequency and energy information
ac = conv(frame,fliplr(frame));
ac = ac(round(length(ac)/2):end);

%Normalize the autocorrelation
e0 = sum(frame.^2);
ek = zeros(size(ac));
for tmp = 1:length(frame)
    ek(tmp) = sum(frame(tmp:end).^2);
end
nccf = ac./(sqrt(e0.*ek));