function [repsection] = combinerep(repetitive,walklabel,time)
% repetitive = repleft | repright;
repsection = [];
ind = find(diff(repetitive));
ind2remove = [];
if (repetitive(1) == 1) && (mod(length(ind),2) == 1)
    repsection(1).startindex = 1;
    repsection(1).endindex = ind(1);
%     n = 1; 
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end 
    for n = 2:length(ind-1)/2+1
        repsection(n).startindex = ind(2*(n-1));
        repsection(n).endindex = ind(2*n-1);  
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end 
    end
elseif (repetitive(1) ~= 1) && (mod(length(ind),2) == 0)
    for n = 1:length(ind)/2
        repsection(n).startindex = ind(2*n-1);
        repsection(n).endindex = ind(2*n);
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end        
    end  
elseif (repetitive(length(repetitive)) == 1) && (mod(length(ind),2) == 1)
    for n = 1:length(ind-1)/2
        repsection(n).startindex = ind(2*n-1);
        repsection(n).endindex = ind(2*n);
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end        
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end       
    end  
    repsection(n+1).startindex = ind(length(ind));
    repsection(n+1).endindex = length(repetitive);
%         startcheck = floor(min(time(repsection(n+1).startindex:repsection(n+1).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n+1).startindex:repsection(n+1).endindex)-time(1)+1));
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n+1).valid = 0;
%             ind2remove = [ind2remove;n];
%         end     
elseif (repetitive(1) == 1) && (repetitive(length(repetitive)) == 1) && (mod(length(ind),2) == 0)
    repsection(1).startindex = 1;
    repsection(1).endindex = ind(1);
    n = 1; 
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end        
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end  
        repsection(1).startindex = 1;
        repsection(1).endindex = ind(1);
    for n = 2:length(ind)/2
        repsection(n).startindex = ind(2*(n-1));
        repsection(n).endindex = ind(2*n-1);
%         startcheck = floor(min(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n).startindex:repsection(n).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end        
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n).valid = 0;
%             ind2remove = [ind2remove;n];
%         end        
    end  
    repsection(n+1).startindex = ind(length(ind));
    repsection(n+1).endindex = length(repetitive); 
%         startcheck = floor(min(time(repsection(n+1).startindex:repsection(n+1).endindex)-time(1)+1));
%         endcheck = ceil(max(time(repsection(n+1).startindex:repsection(n+1).endindex)-time(1)+1));
%         if endcheck>=length(walklabel)
%             endcheck =length(walklabel);
%         end        
%         if length(find(walklabel(startcheck:endcheck)))>=1
%             repsection(n+1).valid = 0;
%             ind2remove = [ind2remove;n];
%         end     
end
repsection=repsection(setdiff(1:length(repsection),ind2remove));
