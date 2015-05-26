% function combine the labels from leftankle and rightankle
function [labelfill,walksection] = combinelabel(labelleft,labelright)
label = zeros(1,length(labelleft));
labelfill = label;
walksection = [];
for n = 1:length(labelleft)
    if (labelleft(n) ==1) && (labelright(n) == 1)
        label(n) = 1;
    end
end

walksection = [];
ind = find(label);
if length(ind) <1
    return;
end
initial = ind(1);
count = 0; 
n = 1; 
labelfill = label;
for n = 1:length(ind)-1
    if(ind(n+1)-ind(n))<=2
        labelfill(ind(n):ind(n+1)) = 1;
        
    end
end

difflabelind = find(diff(labelfill));
% haven't deal with the start and end of labels to be 1
for n = 1:length(difflabelind)/2
    walksection(n).startindex = difflabelind(2*n-1);
    walksection(n).endindex = difflabelind(2*n);
end