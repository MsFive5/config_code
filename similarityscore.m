% determine the similarity
function lenswing = similarityscore(template,input)

len = length(template);
leninput = length(input);
Distance = [];
if length(input)>len
    for n = 0:length(input)-len
%         [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1),input(n:n+len-1,1)-mean(input(n:n+len-1,1)),0);
%         [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2),input(n:n+len-1,2)-mean(input(n:n+len-1,2)),0);
%         [Dist3,temp,temp,temp,temp,temp] = dtw(template(:,3),input(n:n+len-1,3)-mean(input(n:n+len-1,3)),0);
%         Distance = [Distance;Dist1+Dist2+Dist3];
        [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1)-mean(template(:,1)),input(leninput-len+1-n:leninput-n,1)-mean(input(leninput-len+1-n:leninput-n,1)),0);
        [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2)-mean(template(:,2)),input(leninput-len+1-n:leninput-n,2)-mean(input(leninput-len+1-n:leninput-n,2)),0);
        [Dist3,temp,temp,temp,temp,temp] = dtw(template(:,3)-mean(template(:,3)),input(leninput-len+1-n:leninput-n,3)-mean(input(leninput-len+1-n:leninput-n,3)),0);
        Distance = [Distance;Dist2];
    end
    % begin shrinking 
    [minDistance,index] = min(Distance(1:floor(3/4*length(Distance))));
    startindex = leninput-len-index+1;
    endindex = leninput-index;
    currentinput = input(startindex:endindex,:);
    minSDistance = [];
    for n = 1:2
        if (n<=len) && (len-n+1>=n)
        [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1)-mean(template(:,1)),currentinput(n:len-n+1,1)-mean(currentinput(n:len-n+1,1)),0);
        [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2)-mean(template(:,2)),currentinput(n:len-n+1,2)-mean(currentinput(n:len-n+1,2)),0);
        [Dist3,temp,temp,temp,temp,temp] = dtw(template(:,3)-mean(template(:,3)),currentinput(n:len-n+1,3)-mean(currentinput(n:len-n+1,3)),0);
        minSDistance = [minSDistance;Dist2];
        else
            break;
        end
    end
    [minSscore,indexshrink] = min(minSDistance);
    lenswingshrink = len-2*indexshrink+2;
    % begin expanding
    minEDistance = [];
    for n = 0:4
        if ((startindex-n)>=1) &&((endindex+n) <=leninput)
            [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1)-mean(template(:,1)),input(startindex-n:endindex+n,1)-mean(input(startindex-n:endindex+n,1)),0);
            [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2)-mean(template(:,2)),input(startindex-n:endindex+n,2)-mean(input(startindex-n:endindex+n,2)),0);
            [Dist3,temp,temp,temp,temp,temp] = dtw(template(:,3)-mean(template(:,3)),input(startindex-n:endindex+n,3)-mean(input(startindex-n:endindex+n,3)),0);
            minEDistance = [minEDistance;Dist2];      
        else
            break;
        end
    end
    [minEscore,indexexpand] = min(minEDistance);
    lenswingexpand = len +2*indexexpand-2 ;
    if minEscore> minSscore
        lenswing = lenswingshrink;
    else
        lenswing = lenswingexpand;
    end
else
    lenswing = -1;
    return;
end