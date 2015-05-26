%% generate summary
function Gensummary(path,dirname,flag)
normalcoeff = 2.3148e-05/2; % 1 sec num
genfilename= [path '/' 'dialyprocess_' 'walkingeventsummary'];
genfid = fopen(genfilename,'w');
indexArray = [];
labelSection = [];
num = 1; 
if flag == 1
    fprintf(genfid,';Date\tEvent Classification\tStart Time\tEnd Time\tDuration\tAvg.Speed\n');   
else
    fprintf(genfid,';Date\tEvent Classification\tStart Time\tEnd Time\tDuration\tAvg.Speed\tAvg.SwingRatio\n');    
end


    content = dir([path '/' dirname '/' 'dailyprocess_segmentdatawithoutratio_*']);
    distance = 0;
    stepnum = 0; 
    totalWalkingTime = 0;
    for n = 1:length(content)
        count = 1; 
        filename = [path '/' dirname '/' 'dailyprocess_segmentdatawithoutratio_' 'segdata' num2str(n)];
        fid = fopen(filename,'r');
        if fid < 0
            continue;
        else            
            if flag == 1
                valuespeed = fscanf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n');
            else
                valuespeed = fscanf(fid,';max speed is %f, average speed is %f, slowest speed is %f,average ratio is %f\n');                
            end
            speed = valuespeed(2);
            if flag~=1
                ratio = valuespeed(4);
            end
            string = fgetl(fid);
            [ymd,remain] = strtok(string);
            [hmsstart,remain] = strtok(remain);
            [a,b] = strtok(remain);
            [a,stridelen] = strtok(b);
            [stridelen, index] = strtok(stridelen);
            indexArray = [indexArray; str2num(index)];
            labelSection(num).start = str2num(index);
            
            distance = distance + str2num(stridelen);
            starttime = sprintf('%s %s',ymd,hmsstart);
            starttimenum = datenum(starttime);
            stepnum = stepnum + 1; 
            while(1)     
                currentstring = fgetl(fid);              
                stepnum = stepnum + 1; 
                if(ischar(currentstring))
                    endtimestring = currentstring;
                    for mm = 1:4
                        [a,b] = strtok(currentstring);
                        currentstring = b;
                    end
                    [stridelen, index] = strtok(b);
                    indexArray = [indexArray; str2num(index)];   
                    distance = distance + str2num(stridelen);
                else
                    break;
                end
            end
%             % process ratiostring
%             A = sscanf(ratiostring,';average ratio is %f, starttime is %s, endtime is %s');
%             ratio = A(1);
%             fseek(fid,0,'bof'); % come to the beginning of a file
%             for jj = 1:count  % come to last line
%                 endtimestring = fgetl(fid);
%             end    
            
            [ymd,remain] = strtok(endtimestring);
            [hmsend,remain] = strtok(remain);
            endtime = sprintf('%s %s',ymd,hmsend);
            endtimenum = datenum(endtime);
            fclose(fid);
        end
        eventlength(n) = round((endtimenum-starttimenum)/normalcoeff+1);
        if flag == 1
            fprintf(genfid,'%s\twalking\t\t%s\t%s\t%d\t%f\n',ymd,hmsstart,hmsend,eventlength(n),speed);
        else
            fprintf(genfid,'%s\twalking\t\t%s\t%s\t%d\t%f\t%f\n',ymd,hmsstart,hmsend,eventlength(n),speed,ratio);    
        end
    
        labelSection(num).end = str2num(index);
        num = num + 1; 
    end
totalWalkingTime = sum(eventlength);
datapath = path
save([datapath '/results/indexArray.mat'],'indexArray');
save([datapath '/results/labelSection.mat'],'labelSection');
fprintf(genfid,'totoal distance = %f m;\tTotoal Step Number = %d ;\tTotal Walking Time = %d s\n',distance,length(indexArray)*2, sum(eventlength));    
fclose(genfid);
