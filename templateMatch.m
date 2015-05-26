% template match process
function [label,position,stdvalue,distance] = templateMatch(input,template)
templatelen = length(template);
inputlen = length(input);
distance = 1e5*ones(1,inputlen);
position = zeros(1,inputlen);
label = zeros(1,inputlen);
stdvalue = [];
for n = 1:5:inputlen-max(templatelen,40)
    len = 40;
    value = std(input(n:n+len-1,1)) + std(input(n:n+len-1,2))+ std(input(n:n+len-1,3));
    stdvalue = [stdvalue;value];
    if value < 0.5
        continue;
    end
    [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1),input(n:n+templatelen-1,1)-mean(input(n:n+templatelen-1,1)),0);
    [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2),input(n:n+templatelen-1,2)-mean(input(n:n+templatelen-1,2)),0);
    [Dist3,temp,temp,temp,temp,temp] = dtw(template(:,3),input(n:n+templatelen-1,3)-mean(input(n:n+templatelen-1,3)),0);
    currentdistance = Dist1 + Dist2 + Dist3;
    distance(n) = currentdistance;
    if currentdistance <= templatelen
        label(n:n+60) = 1;
        position(n) = 1;
    end
end
