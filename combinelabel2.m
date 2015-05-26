% function combine the labels from leftankle and rightankle
function [labelfill,walksection] = combinelabel2(labelleft,labelright)
label = zeros(1,min(length(labelleft),length(labelright)));
for n = 1:length(label)
    if (labelleft(n) ==1) || (labelright(n) == 1)
        label(n) = 1;
    end
end

walksection = [];
ind = find(label);
if length(ind)==0
    labelfill = zeros(1,length(label));
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
if labelfill(1) ==1 && labelfill(end) ==1 && length(difflabelind)==0
    walksection(1).startindex = 1;
    walksection(1).endindex = length(labelfill);
    return;
end
% haven't deal with the start and end of labels to be 1
if (labelfill(1) == 0) && (labelfill(length(labelfill)) == 0) && (mod(length(difflabelind),2) == 0)
    for n = 1:length(difflabelind)/2
        walksection(n).startindex = difflabelind(2*n-1);
        walksection(n).endindex = difflabelind(2*n);
    end
elseif (labelfill(1) == 1) && (mod(length(difflabelind),2) == 1)
    walksection(1).startindex = 1; 
    walksection(1).endindex = difflabelind(1);
    for n = 2:length(difflabelind)/2+1
        walksection(n).startindex = difflabelind(2*(n-1));
        walksection(n).endindex = difflabelind(2*n-1);
    end  
elseif (labelfill(1)==0)&&(labelfill(length(labelfill)) == 1) && (mod(length(difflabelind),2) == 1)
     for n = 1:length(difflabelind-1)/2
        walksection(n).startindex = difflabelind(2*n-1);
        walksection(n).endindex = difflabelind(2*n);
     end 
     walksection(n+1).startindex = difflabelind(length(difflabelind));
     walksection(n+1).endindex = length(labelfill);   
elseif (labelfill(1) == 1) && (labelfill(length(labelfill)) == 1) && (mod(length(difflabelind),2) == 0)
    walksection(1).startindex = 1; 
    walksection(1).endindex = difflabelind(1);   
    for n = 2:length(difflabelind)/2
        walksection(n).startindex = difflabelind(2*(n-1));
        walksection(n).endindex = difflabelind(2*n-1);
    end    
    if length(n)==0
        walksection(2).startindex = difflabelind(length(difflabelind));
        walksection(2).endindex = length(labelfill);          
    else
        walksection(n+1).startindex = difflabelind(length(difflabelind));
        walksection(n+1).endindex = length(labelfill);          
    end  
end
