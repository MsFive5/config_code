%% group strides
% data is the data structure maintained across this project
% startindex and endindex is the limit of the interested data
% channel is the channel of data that is interested in. Suggested channel
% is the y channel 
% winlen, this value is suggested to set as 45
% samplerate is the sampling rate of signal, for example, 40 Hz. 
function [startoffset,stridesection] = groupstrides(data,startindex,endindex,string,samplerate)
% datainput = data.data;
% if length(data(startindex:endindex,:))<=winlen
%     stridesection = [];
%     return; 
% end
stridesection = [];
startoffset = 0;
datainput = data(startindex:endindex,:);
if strcmp(string,'left')  ==1
    pp1 = datainput(:,2);
    pp2 = datainput(:,4);
elseif strcmp(string,'right')  == 1
    pp1 = datainput(:,5);
    pp2 = datainput(:,7);    
end
pp3 = pp1.^2 + pp2.^2;
indmean = find(pp3>1);
ind2 = find(pp3>0.5);

if mean(pp3(indmean)) <= 1.8 && mean(pp3(ind2))<0.5
    winlen = 60;
elseif mean(pp3(indmean)) <= 2 && mean(pp3(ind2))>=0.5
    winlen = 50;
elseif mean(pp3(indmean)) >2 && mean(pp3(indmean)) <= 2.5
    winlen = 45;
elseif mean(pp3(indmean)) >2.5 && mean(pp3(indmean)) <= 3
    winlen = 40;
elseif mean(pp3(indmean)) >3 && mean(pp3(indmean)) <= 4
    winlen = 35;            
else
    winlen = 30;
end
    if length(data(startindex:endindex,:))<=winlen
        return
    end    

ind = find(pp3>0.2);
if length(ind) ==0
    return;
end
startindex_start = ind(1);
startoffset = startindex_start;
endindex_end = ind(length(ind));
[b,a] = lmax_pw(pp3(startindex_start:endindex_end),winlen);
diffvalue = diff(a);
ind = [];
% to remove nearby multiple points
for n = 1:length(a)
    if b(n)<0.1
        ind = [ind;n];
    end
end
testdata = pp3(startindex_start:endindex_end);
for n = 1:length(diffvalue)
    if diffvalue(n) <= samplerate*0.5
        if testdata(a(n))>=testdata(a(n+1))
            ind2rm = n+1;
        else
            ind2rm = n;
        end
        ind = [ind;ind2rm];
    end
end
% for n = 1:length(a)
%     % skip static or low magnitude data
%     if abs(b(n))<400
%         ind = [ind;n]; 
%     end
% end
index2keep=a(setdiff(1:length(a),ind));
value = datainput(index2keep);
stridenum = length(index2keep);
i = 1;
% stridesection = [];
diffindex = diff(index2keep);
normalindex = find(diffindex<160);
shiftoffset = floor(mean(diffindex(normalindex))/2);

stridesection.index = index2keep+startindex-1+startindex_start+shiftoffset;
stridesection.value = value; 

% stridesection(1).index = index2keep(1);
% stridesection(1).value = value(1);

% for n = 2:length(index2keep)
%     if (index2keep(n)-index2keep(n-1))<5*samplerate
%         stridesection(i).index = [stridesection(i).index;index2keep(n)];
%         stridesection(i).value = [stridesection(i).value;value(n)];
%     else 
%     % segment uncontinuous data        
%         i = i +1; 
%         stridesection(i).index = [index2keep(n)];
%         stridesection(i).value = [value(n)];
%     end
% end

