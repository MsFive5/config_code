% function to combine the result from both NB and DTW
function [walksectionout,finalwalking] = combineNBandDTW(input,label,walksection,NBoutput,path)
finalwalking = NBoutput.classification;
offset = input.data(1,1);
% input.data(:,1) = input.data(:,1) - offset + 1;  
if length(find(NBoutput.classification==1)) == 0 
    finalwalking = zeros(1,length(finalwalking)); 
    walksectionout = [];
    return;
end
for n = 1:length(walksection)
   starttime = input.data(walksection(n).startindex,1)-offset+1;
   endtime = input.data(walksection(n).endindex,1)-offset+1;
   if length(find(finalwalking(floor(starttime):floor(endtime)) == 1))>=1
       finalwalking(floor(starttime):floor(endtime)) = 1; 
   end
end

ind = find(diff(finalwalking));

if (finalwalking(1) == 1) && (mod(length(ind),2) == 1)
    walksectionout(1).starttime = 1;
    walksectionout(1).endtime = ind(1);
    for n = 2:length(ind-1)/2
        walksectionout(n).starttime = ind(2*(n-1));
        walksectionout(n).endtime = ind(2*n-1);        
    end
elseif (finalwalking(1) ~= 1) && (mod(length(ind),2) == 0)
    for n = 1:length(ind)/2
        walksectionout(n).starttime = ind(2*n-1);
        walksectionout(n).endtime = ind(2*n);
    end  
elseif (finalwalking(length(finalwalking)) == 1) && (mod(length(ind),2) == 1)
    for n = 1:length(ind-1)/2
        walksectionout(n).starttime = ind(2*n-1);
        walksectionout(n).endtime = ind(2*n);
    end  
    walksectionout(n+1).starttime = ind(length(ind));
    walksectionout(n+1).endtime = length(finalwalking);
elseif (finalwalking(1) == 1) && (finalwalking(length(finalwalking)) == 1) && (mod(length(ind),2) == 0)
    walksectionout(1).starttime = 1;
    walksectionout(1).endtime = ind(1);
    for n = 1:length(ind-1)/2
        walksectionout(n).starttime = ind(2*n-1);
        walksectionout(n).endtime = ind(2*n);
    end  
    walksectionout(n+1).starttime = ind(length(ind));
    walksectionout(n+1).endtime = length(finalwalking);    
end

for n = 1:length(walksectionout)
    walksectionout(n).starttime = walksectionout(n).starttime + offset - 1;
    walksectionout(n).endtime = walksectionout(n).endtime + offset -1; 
end
save([path '/' 'walksection'],'walksectionout');