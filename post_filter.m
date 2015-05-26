function newlabel = post_filter(oldlabel,walksection,datastruc)
% check for both sensor correlation for itself and correlation between
% sensors
newlabel = oldlabel;
data = datastruc.data;
time = data(:,1)-data(1,1);
sensornum = (size(data,2)-1)/3;
for n = 1:length(walksection)
    if walksection(n).starttime == 0
        walksection(n).starttime = 1;
    end    
    walksection(n).startind = max(find(time<=walksection(n).starttime));
    walksection(n).endind = min(find(time>=walksection(n).endtime));
    curstartind = walksection(n).startind;
    curendind = walksection(n).endind;
    % intra correlation
    for m = 1:sensornum
        if abs(corr2(data(curstartind:curendind,m*3-1),data(curstartind:curendind,m*3)))>0.7||...
      abs(corr2(data(curstartind:curendind,m*3),data(curstartind:curendind,m*3+1)))>0.7||...
      abs(corr2(data(curstartind:curendind,m*3-1),data(curstartind:curendind,m*3+1)))>0.7
            newlabel(floor(walksection(n).starttime):ceil(walksection(n).endtime)) = 0;
        end        
    end

    % inter correlation, only check y axes currently

    if abs(corr2(data(curstartind:curendind,3),data(curstartind:curendind,6)))>0.55
        newlabel(ceil(walksection(n).starttime):ceil(walksection(n).endtime)) = 0;
    end
end

