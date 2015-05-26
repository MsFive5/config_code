% This will calculate the total active time including 
function aTimes = calActiveTime(data, Threshold)
% data : input data. Here we use accel data from both left and right. 
% Threshold: to differentiate active segments from static segments. This
% is an experienced value from previous datasets. 
lx = data(:,1);
ly = data(:,2);
lz = data(:,3);
rx = data(:,4);
ry = data(:,5);
rz = data(:,6);

len = length(data);
aTimes = 0; 
enArray = [];
for n = 120:160:len-160
    currentEn = sqrt(sum(lx(n-119:n).^2) + sum(ly(n-119:n).^2) + sum(lz(n-119:n).^2) + sum(rx(n-119:n).^2) + sum(ry(n-119:n).^2));
    enArray = [enArray; currentEn];
    if currentEn >= Threshold
        aTimes = aTimes + 1; 
    end
end

aTimes = aTimes * 4; 

