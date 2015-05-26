% 
function [cyclesection,repsection] = detectcycling(input,walklabel,datapath,flag)
cyclesection = [];
repsection = [];
data = input.data; 
time = data(:,1);
totalrep = 0;
totaltime = 0;
% [corrallleft,repleft] = corrcal(data(:,2:4),-1);
% [corrallright,repright] = corrcal(data(:,5:7),1);
% repcorr = repleft&repright;
if length(input.header) == 1
    [rep] = repDect(time,data(:,2:4),20); 
    replabel = rep;

else
    [repright] = repDect(time,data(:,2:4),20);
    [repleft] = repDect(time,data(:,5:7),20);  
    replabel = repright|repleft;
   
end

[repsection] = combinerep(replabel,zeros(1,length(walklabel)),time); 
walklabelindex = walklabel(1:1/40:length(walklabel));
if length(walklabelindex) < length(replabel)
    walklabelindex(length(walklabel):length(replabel)) = zeros(1,length(replabel)-length(walklabel)+1);
end
for n = 1:length(repsection)
    startindex = repsection(n).startindex;
    endindex = repsection(n).endindex; 
    if repsection(n).endindex>=length(walklabelindex)
        endindex =length(walklabelindex);
    end
    if length(find(walklabelindex(startindex:endindex)==1))>=1
        continue;
    end
    [b,a] = lmax_pw(data(startindex:endindex,3),40);
    totalrep = totalrep + length(a);
    repsection(n).peakpoints = startindex+a-1;
    totaltime = (endindex - startindex)/40 + totaltime;
end

if exist([datapath '/' 'dailyprocess_realtimerep'],'file') ~= 0
    delete([datapath '/' 'dailyprocess_realtimerep']);
end
fidrep = fopen([datapath '/' 'dailyprocess_realtimerep'],'a+');
fprintf(fidrep,';total number of repetition is %d, total time of repetition is %f\n',totalrep,totaltime);
for n = 1:length(repsection)
    currenttimearray = time(repsection(n).peakpoints);
    for m = 1:length(currenttimearray)
        timestring{m} = datestr(datevec(datenum([input.header{1}.start_date(1) input.header{1}.start_date(2) input.header{1}.start_date(3) input.header{1}.start_time(1) input.header{1}.start_time(2) input.header{1}.start_time(3)+currenttimearray(m)])));
        fprintf(fidrep,'%s\n',timestring{m});
    end
end
fclose(fidrep);
walkstepnum=GenFinalSummary(datapath,flag);
fidfinal = fopen([datapath '/' 'dailyprocess_finalwalkingsummary'],'a+');
fprintf(fidfinal, 'Total Number of Repetiton is %d\n',totalrep+walkstepnum);
fprintf(fidfinal,'Total Time for Repetitive Activity is %f s\n',totaltime+length(find(walklabel==1)));
fclose(fidfinal);

% cyclelabel = repcorr&repright&repleft ;
% [cyclesection] = combinerep(cyclelabel,walklabel,time);
% 
% totalnumofrep = 0; 
% for n = 1:length(cyclesection)
%     % add the code to either normalize the native data or calculate the
%     % local energy to determine the window sizes
%     [b,a] = lmax_pw(data(cyclesection(n).startindex:cyclesection(n).endindex,3),25);
%     totalnumofrep = totalnumofrep + length(a);
%     cyclesection(n).peakpoints = cyclesection(n).startindex+a -1; 
% end



% if exist([datapath '/' 'pedalinglog.txt'],'file') ~= 0
%     delete([datapath '/' 'pedalinglog.txt']);
% end
% 
% fid = fopen([datapath '/' 'pedalinglog.txt'],'a+');
% fprintf(fid,';total number of pedal is %d\n',totalnumofrep);
% for n = 1:length(cyclesection)
%     currenttimearray = time(cyclesection(n).peakpoints);
%     for m = 1:length(currenttimearray)
%         timestring{m} = datestr(datevec(datenum([input.header{1}.start_date(1) input.header{1}.start_date(2) input.header{1}.start_date(3) input.header{1}.start_time(1) input.header{1}.start_time(2) input.header{1}.start_time(3)+currenttimearray(m)])));
%         fprintf(fid,'%s\n',timestring{m});
%     end
% end
% fclose(fid);



