% Gen final summary
function  GenFinalSummary(datapath,flag, aTimes)
if exist([datapath '/' 'dailyprocess_finalwalkingsummary'],'file') ~= 0
    delete([datapath '/' 'dailyprocess_finalwalkingsummary']);
end
finalsummary = fopen([datapath '/' 'dailyprocess_finalwalkingsummary'],'w');

% get the total number of steps
% if (flag == 1) || (flag < 0)
%     fidrealtime = fopen([datapath '/' 'dailyprocess_realtimeresultwithoutratio'],'r');
%     realtimeinfo = fscanf(fidrealtime,'number of steps is %d, total distance is %f');
%     fclose(fidrealtime);
% elseif flag == 2
%     fidrealtime = fopen([datapath '/' 'dailyprocess_realtimeresultwithratio'],'r');
%     realtimeinfo = fscanf(fidrealtime,'number of steps is %d, total distance is %f');
%     fclose(fidrealtime);    
%    
% end


% get maintainable maximal speed, avg speed and lowest speed
if flag < 0
    fprintf(finalsummary,'Total Number of Steps is 0\n');
    fprintf(finalsummary,'Total Distance is 0.0 m\n');
    fprintf(finalsummary,'Maximal Speed is 0.0 m/s \n');
    fprintf(finalsummary,'Average Speed is 0.0 m/s \n');
    fprintf(finalsummary,'Minimal Speed is 0.0 m/s \n');    
else
    fid = fopen([datapath '/' 'dialyprocess_walkingeventsummary'],'r');
    if fid<0
        return;
    end
    lastLine = '';
    offset = 1; 
    fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
    newChar = fread(fid,1,'*char');  %# Read one character
    while (~strcmp(newChar,char(10))) || (offset == 1)
        lastLine = [newChar lastLine];   %# Add the character to a string
        offset = offset+1;
        fseek(fid,-offset,'eof');        %# Seek to the file end, minus the offset
        newChar = fread(fid,1,'*char');  %# Read one character
    end
    fclose(fid);
%     [distance,step] = strtok(lastLine);
    c = strsplit(lastLine);
    

    fprintf(finalsummary,'Total Number of Steps is %d\n',str2double((c(10))));
%     fprintf(finalsummary,'Total Distance is %f m\n',str2num(distance));
    fprintf(finalsummary,'Total Distance is %f m\n',str2double(char(c(4))));
    fprintf(finalsummary,'Total Walking Time is %d s\n',str2double(char(c(16)))); 
    contentevent = importdata([datapath '/' 'dialyprocess_walkingeventsummary']);
    dataevent = contentevent.data;        
    fprintf(finalsummary,'Maximal Speed is %f m/s \n',max(dataevent(:,2)));
    fprintf(finalsummary,'Average Speed is %f m/s \n',mean(dataevent(:,2)));
    fprintf(finalsummary,'Minimal Speed is %f m/s \n',min(dataevent(:,2)));
end
% write total active time into the final summary
fprintf(finalsummary, 'Total Active Time is %d s\n', aTimes);
fclose(finalsummary);


