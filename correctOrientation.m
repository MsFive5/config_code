% 
function output = correctOrientation(input)
output.header = input.header;
output.data = input.data;
time = input.data(:,1);
dataxl = input.data(:,2);
datayl = input.data(:,3);
datazl = input.data(:,4);
dataxr = input.data(:,5);
datayr = input.data(:,6);
datazr = input.data(:,7);


% % correct if the sensor is reverse down
% if mean(datayl) >0 && mean(dataxl)<0
%     output.data(:,2) = input.data(:,2)*(-1);
%     output.data(:,3) = input.data(:,3)*(-1);
% end

for n = 1:40*60:length(input.data)
    startindex = n;
    endindex = n+40*60-1;
    if endindex>=length(input.data)
        endindex = length(input.data);
    end
    if mean(datayl(startindex:endindex)) >0 
        output.data(startindex:endindex,2) = input.data(startindex:endindex,2)*(-1);
        output.data(startindex:endindex,3) = input.data(startindex:endindex,3)*(-1);
    end  
    if mean(datayr(startindex:endindex)) >0 
        output.data(startindex:endindex,5) = input.data(startindex:endindex,5)*(-1);
        output.data(startindex:endindex,6) = input.data(startindex:endindex,6)*(-1);
    end 
end
padindex = find(diff(time)>=0.5); % pad 0 when the time difference is larger than 0

while(length(padindex)>=1)
    padarray = [];
    padarray(:,1) = time(padindex(1))+[1/40:1/40:time(padindex(1)+1)-time(padindex(1))];
    padlen = length(padarray(:,1));   
    padarray(:,2:7) = zeros(padlen,6);
    finaldata = [output.data(1:padindex(1),:);padarray(1:padlen,:);output.data(padindex(1)+1:length(output.data),:)];
    output.data = finaldata;
    time = output.data(:,1);
    padindex = find(diff(time)>=0.5);
end

% pad data when sensor plugged into the computer accidentally

% in area 1  
% corr<0 
% meanx<0
% meanz >0

% in area 2 
% corr>0 
% meanx>0
% meanz >0


% in area 3
% corr<0 
% meanx>0
% meanz <0

% in area 4
% corr>0 
% meanx<0
% meanz <0
