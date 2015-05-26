function [newdata, startindex, endindex] = trimWhiteSpace(data, THRESH, sampleRate)
startindex = 1;
endindex = length(data);
for n = 2 : floor(length(data)/sampleRate)
    if sum(std(data((n-1) * sampleRate : n * sampleRate, 2 : 4)))/2048 >= THRESH
        startindex = n * sampleRate;
        break;
    end
end

for n = floor(length(data)/sampleRate) : -1 : 1
    if sum(std(data((n-1) * sampleRate : n * sampleRate, 2 : 4)))/2048 >= THRESH
        endindex = n * sampleRate;
        break;
    end
end

newdata = data(startindex : endindex, :);
