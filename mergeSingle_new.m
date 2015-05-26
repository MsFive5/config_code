function [outputData, outputTime] = mergeSingle_new(input, sampleRate)
TIMEDIFF = 25;
output = [];
output = input{1}.data;

for n = 1:length(input)
    % pad 0s to gaps within file  
    time = input{n}.time;
    data = input{n}.data;
    ind = find(diff(time)~=25);
    for m = 1:length(ind) 
        delta = time(ind(m))-time(ind(m)+1);
        if(delta == 0) % same timestamp
            data = [data(1:ind(m),:);data(ind(m)+2:end,:)];
            ind = ind - 1; 
        elseif(delta < 0)
            padLen = abs(delta)/TIMEDIFF - 1;
            data = [data(1:ind(m),:); zeros(padLen,size(data,2));data(ind(m)+1:end,:)];
            ind = ind + padLen;
        else % 
            ind
        end
    input{n}.data = data;         
    end
end

for n = 1 : length(input)
%     output = [output; input{n}.data];
    % pad 0s to seal time jumps between files
    if(n ~= length(input))
        padArraylen = (input{n+1}.time(1)- input{n}.time(end))/TIMEDIFF;
        output = [output; zeros(padArraylen, size(input{n}.data, 2));input{n+1}.data];
    %else
    %    output = [output; input{n}.data];
    end
end

outputTime = input{1}.time(1) : 1e3/sampleRate : input{1}.time(1) + (length(output) - 1) * 1e3 / sampleRate;
outputData = output;
