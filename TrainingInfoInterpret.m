% TrainingInfoInterpret
function sensor_info = TrainingInfoInterpret(datapath)
sensor_info = [];
leftfile = dir([datapath '/' 'training_*_left.txt']);
rightfile= dir([datapath '/' 'training_*_right.txt']);
name = {[datapath '/' leftfile.name];[datapath '/' rightfile.name]};
for n = 1:2
    content = importdata(name{n});
    filelen = length(content);
    [a,b] = strtok(leftfile.name,'training_');    
    sensor_info{n}.patientID = a;
    for m = 8:filelen
        sensor_info{n}.files{m-7} = content{m};
    end
    [a,b] = strtok(content{3},';');
    sensor_info{n}.numofbout = a;
    [a,b] = strtok(content{4},';');
    sensor_info{n}.boutlength = a; % convert from foot to meter
    [a,b] = strtok(content{7},';');
    sensor_info{n}.hemiside = a;
    
    ind = strfind(content{8}, '/Template-');
    sensor_info{n}.datapath = content{8}(1:ind);
%     fid = fopen(sensor_info{n}.files{1},'r');
%     fgetl(fid);
%     string = fgetl(fid);
%     fclose(fid);
%     [a,b] = strtok(string,'CCDC');
%     sensor_info{n}.sensorSerial = b;
%     if n == 1
%         sensor_info{n}.sensorName = 'left';
%     else
%         sensor_info{n}.sensorName = 'right';
%     end
    
end


