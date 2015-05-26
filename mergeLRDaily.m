% merge data from left sensor and right sensor
function data = mergeLRDaily(timeL, dataL, timeR, dataR, sampleRate)
width = size(dataL, 2);
if timeL(1) >= timeR(1)
    startTime = timeR(1);
    startDiff = timeL(1) - timeR(1);
    padLength = round(startDiff * sampleRate / 1e3);
    dataL = [zeros(padLength, width); dataL];
else
    startTime = timeL(1);
    startDiff = timeR(1) - timeL(1);
    padLength = round(startDiff * sampleRate / 1e3);
    dataR = [zeros(padLength, width); dataR];    
end

if timeL(end) >= timeR(end)
    endDiff = timeL(end) - timeR(end);
    padLength = round(endDiff * sampleRate / 1e3);  
    dataR = [dataR; zeros(padLength, width)];
else
    endDiff = timeR(end) - timeL(end);
    padLength = round(endDiff * sampleRate / 1e3);  
    dataL = [dataL; zeros(padLength, width)];
end

len = min(length(dataL), length(dataR));
time = startTime : 1e3/sampleRate : startTime + (len - 1) * 1e3/sampleRate;
data = [time' dataL(1:len,:) dataR(1:len,:)];




