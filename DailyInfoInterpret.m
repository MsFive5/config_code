% daily info txt file interpret
function sensor_info = DailyInfoInterpret(datapath)
sensor_info = [];
leftfile = dir([datapath '/' 'dailyprocess_*_left.txt']);
rightfile = dir([datapath '/' 'dailyprocess_*_right.txt']);
name = {[datapath '/' leftfile.name];[datapath '/' rightfile.name]};
for n = 1:2
    fid = fopen(name{n},'r');
    if fid <0    %if one .txt file is missing
       continue; 
    end    
    timestamp = fgetl(fid);
    if timestamp<0  % when one .txt file is null
        continue;
    end    
%     [a,b] = strtok(timestamp,' ');
%     [year,b] = strtok(a,'-');
%     [mon,b] = strtok(b,'-');
%     [day,b] = strtok(b,'-');
    count = 0;
    while ~feof(fid) 
        count = count + 1;
        sensor_info{n}.files{count} = fgetl(fid);
    end  
    fclose(fid);
    
    ind = strfind(sensor_info{n}.files{count}, '/Daily-Activity_');
    sensor_info{n}.datapath = sensor_info{n}.files{count}(1:ind); 
    
%     datafid = fopen(sensor_info{n}.files{1},'r');
%     fgetl(datafid);
%     string = fgetl(datafid);
%     fclose(datafid);
%     [a,b] = strtok(string,'CCDC');
%     sensor_info{n}.sensorSerial = b;
%     if n == 1
%         sensor_info{n}.sensorName = 'left';
%     else
%         sensor_info{n}.sensorName = 'right';
%     end
    [patientID,b] = strtok(name{n},'dailyprocess_');
    mergename = [datapath '/' 'dailyprocessMerge.mat'];
    sensor_info{n}.mergename = mergename;
    
end
