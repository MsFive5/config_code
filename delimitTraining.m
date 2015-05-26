%% delimit the training part
function [trainingsection,true,distance,flag] = delimitTraining(inputDatastructure,templatestructure,threshold,numofbouts)
flag = 1;
trainingsection = [];
true = 1;
template = templatestructure.data;
templateheader = templatestructure.header;
templatelen = length(template);
input = inputDatastructure.data;
inputheader = inputDatastructure.header;
inputlen = length(input);
if inputlen<templatelen
    return;
end
count = 0; 
iterationlength = floor((inputlen-templatelen)/40);
distance = 1e4*ones(1,iterationlength);
for n = 1:40:inputlen - templatelen
    count = count + 1; 
    currentdata = input(n:n+templatelen,:);
    if (std(currentdata(:,2)) + std(currentdata(:,3)) + std(currentdata(:,4)))<0.1
        continue;
    else
        [D1,Dist,k,w,rw,tw] = dtw(currentdata(:,2)-mean(currentdata(:,2)),template(:,2)-mean(template(:,2)),0);    
        [D2,Dist,k,w,rw,tw] = dtw(currentdata(:,3)-mean(currentdata(:,3)),template(:,3)-mean(template(:,3)),0); 
        [D3,Dist,k,w,rw,tw] = dtw(currentdata(:,4)-mean(currentdata(:,4)),template(:,4)-mean(template(:,4)),0); 
        distance(count) = D1 + D2 + D3;
    end
end

indset = find(distance<=threshold);
if length(indset) <1
    flag = -1;
    return;
end
diffindset = diff(indset);
ind = find(diffindset>10);
if (length(ind)+1) == numofbouts
    true = 1;
else
    true = 0;
    % add code later if number of signature is larger/smaller than number of bouts
end

countsignature = 1; 
signature(countsignature).start = indset(1);
for n = 1:length(indset)-1
    if (indset(n+1)-indset(n))<10
        signature(countsignature).end = indset(n+1);
    else
        signature(countsignature).end = indset(n);
        countsignature = countsignature + 1;
        signature(countsignature).start = indset(n+1);
    end
end
signature(countsignature).end = indset(length(indset));

for m = 1:countsignature
    [a,b] = min(distance(signature(m).start:signature(m).end));
    signature(m).sigpoint = signature(m).start + b -1;
    [D,Dist,k,w,rw,tw] = dtw(input(signature(m).sigpoint*40:signature(m).sigpoint*40+templatelen+10,2),template(:,2),0);
    trainingsection(m).start = (signature(m).sigpoint)*40 + length(unique(w(:,1)));
end

for n = 1:countsignature
    for m = trainingsection(n).start:40:inputlen-40
        if (std(input(m:m+40,2)) + std(input(m:m+40,3)) + std(input(m:m+40,4)))>0.05
            continue;
        else
            trainingsection(n).end = m;
            break;
        end
    end
end
index2remove = [];
for n = 1:length(trainingsection)
    if (trainingsection(n).end - trainingsection(n).start+1) <=5
        trainingsection(n).valid = 0;
        index2remove = [index2remove;n];
    else
        trainingsection(n).valid = 1; 
    end
end
trainingsection = trainingsection(setdiff(1:length(trainingsection),index2remove));
















