function [fratio,vf] = sse_fratio_measure_fn(data, fftSize, fft_threshold)

vf = fft(data,fftSize);
vindex = find(abs(vf(1:fftSize/2))>=fft_threshold);
if length(vindex) == 0
    fratio = 0;
else
    startpoint = vindex(1); 
    endpoint   = vindex(length(vindex));
    fratio     = sum(abs(vf(startpoint:endpoint)))...
                 ./sum(abs(vf(1:fftSize/2)));
end