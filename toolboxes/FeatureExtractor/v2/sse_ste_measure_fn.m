function [ste] = sse_ste_measure_fn(data, lmax_winSize, delta)

%Autocorrelation
[e0,nccf_data] = nacf(data);

%Now find the maxima to determine the delta between the
%peaks fodatar frequency determination
[maxval maxind] = lmax(nccf_data,lmax_winSize);

% plot(1:length(nccf_data),nccf_data,'b-', ...
%      maxind, nccf_data(maxind_v),'r.');

absmax = find(maxval==max(maxval));
if(length(absmax) > 1)
    absmax = absmax(1);
end

absmaxind = maxind(absmax);
nccf_peak = max(maxval);

ste = e0/delta;