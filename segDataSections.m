function rv = segDataSections(path,flag)
if  flag == 1
    data = importdata([path '/' 'dailyprocess_realtimeresultwithoutratio']);
else
    data = importdata([path '/' 'dailyprocess_realtimeresultwithratio']);
end

time = [];
para = [];
indexnum = [];
normalcoeff = 2.3148e-05/2;
% check the existence of the directory
if flag==1 % segment data without ratio
    dirname = 'dailyprocess_segmentdatawithoutratio';
    label = exist(dirname,'dir');
    if label ~= 0 % there is a dir there
        rmdir([path '/' dirname],'s');
    end
    mkdir([path '/' dirname]);
%     cd(dirname);
else % segment data with ratio
    dirname = 'dailyprocess_segmentdatawithratio';
    label = exist(dirname,'dir');
    if label ~= 0 % there is a dir there
        rmdir([path '/' dirname],'s');
    end
    mkdir([path '/' dirname]);
%     cd(dirname);
end
filestring = [dirname '_'];
for n = 3:length(data) % real data starts from 3rd line
    [ymd,remain] = strtok(data{n});    
    [hms,remain] = strtok(remain);
    currenttimestring = sprintf('%s %s',ymd,hms);
    currenttimeindex= datenum(datevec(currenttimestring))/normalcoeff;
    currenttime.string = currenttimestring;
    currenttime.index = currenttimeindex;
    time = [time;currenttime];    
    [para1,pararemain] = strtok(remain);
    [para2,pararemain] = strtok(pararemain);
    [para3,pararemain] = strtok(pararemain);
    index = pararemain;
    
    if flag == 1
        
        para = [para;[str2num(para1) str2num(para2) str2num(para3)] str2num(index)];
    else
        [para4,pararemain] = strtok(pararemain);
        para = [para;[str2num(para1) str2num(para2) str2num(para3) str2num(para4)]];
    end

end

for m = 1:length(time)
    indexnum = [indexnum;time(m).index];
end

segindex = find(diff(indexnum)>10);   % time length
if length(segindex)<1 
%     rv = -1;
%     return;
    if flag == 1
        countfile = writefilewithoutratio(path,dirname,filestring,1,length(indexnum),1,time,para);
        rv = 1;
        Gensummary(path,dirname,flag);        
        return;
    end
end
countfile = 1; 
for n = 1:length(segindex)+1
    if (n==1)
        if segindex(1)<=5  % number of steps
            ;
        elseif segindex(1)>4
            if flag == 1
                countfile = writefilewithoutratio(path,dirname,filestring,1,segindex(1),countfile,time,para);
            else
                countfile = writefile(path,dirname,filestring,1,segindex(1),countfile,time,para);
            end
        end
    elseif(n<=length(segindex))
        if (segindex(n)-segindex(n-1))<=5 % number of steps
        else
            if flag == 1
                countfile = writefilewithoutratio(path,dirname,filestring,segindex(n-1)+1,segindex(n),countfile,time,para);
            else
                countfile = writefile(path,dirname,filestring,segindex(n-1)+1,segindex(n),countfile,time,para);
            end
        end
    else        
        if (length(para)-segindex(length(segindex)))<=5  % number of steps
        else
            if flag ==1
                countfile = writefilewithoutratio(path,dirname,filestring,segindex(length(segindex))+1,length(para),countfile,time,para);
            else
                countfile = writefile(path,dirname,filestring,segindex(length(segindex))+1,length(para),countfile,time,para);
            end
        end
    end
end

rv = 1;         
Gensummary(path,dirname,flag);
return;