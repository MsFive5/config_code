function [repetitive] = repDect(time,input,threshold,repunit)
data = input;
sdvalue = [];
corrall = [];
repetitive = zeros(1,length(data));
replen = repunit*40;
looplen = fix(length(data)/replen);

matrixx = reshape(data(1:looplen*replen,1),replen,looplen);
matrixy = reshape(data(1:looplen*replen,2),replen,looplen);
matrixz = reshape(data(1:looplen*replen,3),replen,looplen);
matrixtime = reshape(time(1:looplen*replen),replen,looplen);
stdx = std(matrixx);
stdy = std(matrixy);
stdz = std(matrixz);
stdvalue = stdx+stdy+stdz;

% for x = time(1):max(time)-1
%     startindex = max(find(time<=x));
%     endindex = min(find(time>=(x+1)));
%     currentframe = data(startindex:endindex,:);
%     currentsd.valuex = std(currentframe(:,1));
%     currentsd.valuey = std(currentframe(:,2));
%     currentsd.valuez = std(currentframe(:,3));
%     currentsd.time = x;
%     sdvalue = [sdvalue;currentsd];       
% end
% 
for n = 1:looplen
    timeplot(n) = matrixtime(1,n);
%     sd(n) = sdvalue(n).valuex+sdvalue(n).valuey+sdvalue(n).valuez;
end

ind = find(stdvalue>0.5);
m = 1; 
while(m<(length(ind)-1))
    number = 0; 
    if ((timeplot(ind(m+1))-timeplot(ind(m)))>=(repunit+2-1e-4))
        m = m +1; 
        continue;
    else    
        startindex = findindex(time,timeplot(ind(m)));
        endindex = findindex(time,timeplot(ind(m))+4)-1;
        template.time = timeplot(ind(m));
        template.x = data(startindex:endindex,1);
        template.y = data(startindex:endindex,2);
        template.z = data(startindex:endindex,3);
        
        nextframe.time = timeplot(ind(m+1));
        nextframe.x = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,1);
        nextframe.y = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,2);
        nextframe.z = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,3);  
        [scorex,temp,temp,temp,temp,temp] = dtw(template.x-mean(template.x),nextframe.x-mean(nextframe.x),0);
        [scorey,temp,temp,temp,temp,temp] = dtw(template.y-mean(template.y),nextframe.y-mean(nextframe.y),0);
        [scorez,temp,temp,temp,temp,temp] = dtw(template.z-mean(template.z),nextframe.z-mean(nextframe.z),0);
        score = scorex+scorey+scorez;
        if score<threshold
            if startindex <replen
                repetitive(startindex:findindex(time,timeplot(ind(m+1))+repunit)-1) = 1;
            else
                repetitive(startindex-replen:findindex(time,timeplot(ind(m+1))+repunit)-1) = 1;    
            end
            
            while ((timeplot(ind(m+1))-timeplot(ind(m)))<(repunit+2-1e-4))
                m = m + 1; 
                if (m>=length(ind))
                    return;
                end
                % update template                  
                template = nextframe;
                nextframe.time = timeplot(ind(m+1));
                nextframe.x = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,1);
                nextframe.y = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,2);
                nextframe.z = data(findindex(time,timeplot(ind(m+1))):findindex(time,timeplot(ind(m+1))+4)-1,3);     
                [scorex,temp,temp,temp,temp,temp] = dtw(template.x-mean(template.x),nextframe.x-mean(nextframe.x),0);
                [scorey,temp,temp,temp,temp,temp] = dtw(template.y-mean(template.y),nextframe.y-mean(nextframe.y),0);
                [scorez,temp,temp,temp,temp,temp] = dtw(template.z-mean(template.z),nextframe.z-mean(nextframe.z),0);
                 score = scorex+scorey+scorez;
                 if score<threshold 
                    repetitive(findindex(time,timeplot(ind(m+1)))-replen:findindex(time,timeplot(ind(m+1))+repunit)-1) = 1;    
                 end                    
            end 
        else
            m = m +1; 
        end
    end   
end
