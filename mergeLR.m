% merge data from left sensor and right sensor
function newdata = mergeLR(timeL, dataL, timeR, dataR, sampleRate)
width = size(dataL, 2);
lsind = 1; 
rsind = 1;
leind = length(timeL);
reind = length(timeR);

if timeL(1) >= timeR(1)
    startTime = timeL(1);
    rsind = find(timeR >= startTime, 1, 'first');
else
    startTime = timeR(1);
    lsind = find(timeL >= startTime, 1, 'first');
end

if timeL(end) >= timeR(end)
    endTime = timeR(end);
    leind = find(timeL <= endTime, 1, 'last');
else
    endTime = timeL(end);
    reind = find(timeR <= endTime, 1, 'last');
end

dataL = dataL(lsind : leind, :);
dataR = dataR(rsind : reind, :);
len = min(length(dataL), length(dataR));

newTime = startTime : 1e3/sampleRate : startTime + (len - 1) * 1e3/sampleRate;
newdata = [newTime' dataL(1 : len, :) dataR(1 : len, :)];




