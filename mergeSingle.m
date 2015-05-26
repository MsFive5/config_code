function [outputData, outputTime] = mergeSingle(input, sampleRate)
output = [];
for n = 1 : length(input)
    output = [output; input{n}.data];
end

outputTime = input{1}.time(1) : 1e3/sampleRate : input{1}.time(1) + (length(output) - 1) * 1e3 / sampleRate;
outputData = output;
