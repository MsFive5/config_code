% function to combine the result from both NB and DTW
function [walksectionout] = combineNBandDTW(input,label,walksection,NBoutput,path,finalwalking)
% padzerolen= floor(NBoutput.starttime);
% % NBoutput.classification = [zeros(1,padzerolen) NBoutput.classification];
% 
% finalwalking = NBoutput.classification;
% % finalwalking = label(1:40:length(label));
% offset = input.data(1,1);
% if length(find(NBoutput.classification==1)) == 0 
%     finalwalking = zeros(1,length(finalwalking)); 
%     walksectionout = [];
%     return;
% end
% % input.data(:,1) = input.data(:,1) - offset + 1;  
% for n = 1:length(walksection)
%    starttime = input.data(walksection(n).startindex,1)+1-offset;
%    if  walksection(n).endindex>= length(input.data)
%        endtime = input.data(length(input.data),1)+1-offset;
%    else
%        endtime = input.data(walksection(n).endindex,1)+1-offset;       
%    end
%    if length(finalwalking)<=endtime   
%        endtime = length(finalwalking);
%    end
%    if length(find(finalwalking(floor(starttime):floor(endtime)) == 1))>=1
%        finalwalking(floor(starttime):floor(endtime)) = 1; 
% %    elseif length(find(finalwalking(floor(starttime):floor(endtime)) == 1))<1 && (endtime-starttime)>4
% %        finalwalking(floor(starttime):floor(endtime)) = 0;
%    end
% %    if (endtime-starttime)<=2
% %        finalwalking(floor(starttime):floor(endtime)) = 0;
% %    end
% end

ind = find(diff(finalwalking));
if length(ind) <= 1 
    if finalwalking(1)==1 && length(find(finalwalking==1))>1
        if finalwalking(end) == 1
            walksectionout(1).starttime = 1;
            walksectionout(1).endtime = length(finalwalking); 
            return;
        else
            walksectionout(1).starttime = 1;
            walksectionout(1).endtime = ind;  
            return;
        end

    elseif length(find(finalwalking == 1))<=1
        walksectionout = [];
        return;
    else
        walksectionout(1).starttime = ind + 1; 
        walksectionout(1).endtime = length(finalwalking);
        return;
    end
end
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
    for n = 2:length(ind-1)/2
        walksectionout(n).starttime = ind(2*(n-1));
        walksectionout(n).endtime = ind(2*n-1);
    end  
    walksectionout(n+1).starttime = ind(length(ind));
    walksectionout(n+1).endtime = length(finalwalking);    
end

for n = 1:length(walksectionout)
    walksectionout(n).starttime = walksectionout(n).starttime  - 1;
    walksectionout(n).endtime = walksectionout(n).endtime -1; 
end
save([path '/' 'walksection'],'walksectionout');