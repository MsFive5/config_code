% testing routine
% clear all; close all; 
function [cyclesection] = dailyprocessroutine_new(trainingpath,datapath, configFile)
% trainingpath = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/training';
% path = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/20100915';
% timestart = tic;
cyclesection = [];
sampleRate = 40;
% config file interpret; added by Celia on 05/04/15
% configFile = [configPath '/configFile.txt'];
configStruc = interpretConfig(configFile);
% if exist([datapath '/' 'dailyprocessMerge.mat'])>0
%     sensor_info = DailyInfoInterpret(datapath);
% else
%     sensor_info = MergeProcess('dailyprocess',datapath);    
% end

% if exist([trainingpath '/' 'fullstridetemplate.mat'])==0
%     return;
% else
% end


% file interpret with WHI sensor
% files = dir([datapath '/' '*.data']);
% fileCount = 0;
% for n = 1 : length(sensor_info)
%     for m = 1 : length(sensor_info{n}.files)
%         fileCount = fileCount + 1; 
%         files(fileCount).name = strrep(sensor_info{n}.files{m}, sensor_info{1}.datapath,'');
%     end
% end


dataLcell = {};
dataRcell = {};
Lcount = 0; 
Rcount = 0;
% for n = 1 : length(files)
%     cFile = files(n).name;
%     [a, b] = strtok(files(n).name, 'Daily-Activity_');
%     if strcmp(a, 'L') == 1 % the left sensor
%         Lcount = Lcount + 1; 
%         [timeL, dataL] = interpretDataFile([sensor_info{1}.datapath  cFile]);
%         dataLcell{Lcount}.data = dataL;
%         dataLcell{Lcount}.time = timeL;
%     else % the right sensor
%         Rcount = Rcount + 1; 
%         [timeR, dataR] = interpretDataFile([sensor_info{1}.datapath  cFile]);
%         dataRcell{Rcount}.data = dataR;
%         dataRcell{Rcount}.time = timeR; 
%     end    
% end

% % Merge single side multiple files % 
% [newL, newtimeL] = mergeSingle_new(dataLcell, sampleRate);
% [newR, newtimeR] = mergeSingle_new(dataRcell, sampleRate);
%  
% mergeData = mergeLRDaily(newtimeL, newL, newtimeR, newR, sampleRate);
mergeData = [];
temp = csvread([datapath '/merged.csv']);
% mergeData(:, 1:11) = temp(1:5000,1:11); % tempory testing
% mergeData(:,12:21) = temp(1:5000, 13:end);%temporary testing
mergeData(:, 1:11) = temp(:,1:11);
mergeData(:,12:21) = temp(:, 13:end);

mergeData = padZeros(mergeData);
% mergeData = mergeData(1:10000,:); %commented temporarily by Celia
% need to make the header
% create a fake header here
header{1}.sensorName = 'L';
header{1}.sampleRate = sampleRate;
% get sensor time
% for n = 1:length(mergeData)
%     matlabtime(n) = unix2matlab(mergeData(n,1));
% end
matlabtime = [];
matlabtime = unix2matlab(mergeData(:,1)');
matlabtime = matlabtime';
startTime = datevec(matlabtime(1));

start_date = [startTime(1)  startTime(2)  startTime(3)];
start_time = [startTime(4) startTime(5) 0];
header{1}.start_date = start_date;
header{1}.start_time = start_time; 
header{1}.sample_rate = sampleRate;
headertime = datenum([start_date start_time]);
secArray = (matlabtime' - headertime)*24*60*60;
mergeData(:,1) = secArray(:,end);

header{2} = header{1};

header{2}.sensorName = 'R';


% sensor orientation correction
mergeC = mergeData;
mergeC(:,2) = mergeData(:,4)*(-1);
mergeC(:,3) = mergeData(:,2);
mergeC(:,4) = mergeData(:,3);

mergeC(:,5) = mergeData(:,7)*(-1);
mergeC(:,6) = mergeData(:,5);
mergeC(:,7) = mergeData(:,6);

% input.data = [mergeData(:,1) mergeData(:, 2 : 4)/2048 mergeData(:, 12:14 )/2048];
if strcmp(configStruc{1}.value{1}, 'True') == 1
    input.data = [mergeC(:,1) mergeC(:, 2 : 4)/2048 mergeC(:, 12:14 )/2048];
else
    input.data = [mergeData(:,1) mergeData(:, 2 : 4)/2048 mergeData(:, 12:14 )/2048];
end
input.header = header;


template = load([trainingpath '/' 'fullstridetemplate.mat']);
trainingsensor_info= load([trainingpath '/trainingsensor_info.mat']);
output.header = input.header;
output.data = input.data;

 
data = mergeData; 
header = output.header
save([datapath '/' 'dailyprocessMerge.mat'],'data', 'header');

% for n = 1:length(sensor_info)
%     sensor_info{n}.hemiside = trainingsensor_info.sensor_info{1}.hemiside;
% end

% no data 
if length(input.data) ==0
    return;
end
% output = correctOrientation(input);
if length(output.data) == 0
    return;
end
% output.data(:,2:7) = output.data(:,2:7)/340;

% use dtw to characterize walksection
[labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.left, str2num(configStruc{3}.value{1}));
[labelright,positionright,stdvalue,distance] = templateMatch2(output.data(:,5:7),template.right, str2num(configStruc{3}.value{1}));
[label,walksectiondtw] = combinelabel2(labelleft,labelright);

% use NB to characterize walksection
trainingstructure = load([trainingpath '/' 'NaiveBayes_training.mat']);
NBoutput = DailyProcess(output,trainingstructure,trainingpath,trainingsensor_info.sensor_info, str2num(configStruc{2}.value{1}));

% combine the result from NB and DTW
walklabel = generatewalklabel(output,label,walksectiondtw,NBoutput,datapath);
if length(find(walklabel))<1
    fid = fopen([datapath '/' 'datablank'],'w');
    fclose(fid);
    return;
end
[walksection] = combineNBandDTW2(output,label,walksectiondtw,NBoutput,datapath,walklabel);
walklabel2 = walklabel;
% walklabel2 = post_filter(walklabel,walksection,output);
mkdir([datapath '/results/'])
save([datapath '/results/' 'walklabel.mat'],'walklabel');

% Generate total active time
aTimes = calActiveTime(output.data(:,2:7),15);

para = load([trainingpath '/' 'training_para.mat']);
if length(walksection) == 0
    savefilename = [datapath '/' 'dailyprocess_','realtimeresultwithoutratio']; 
    fid = fopen(savefilename,'w');
    fprintf(fid,'number of steps is 0, total distance is 0.0\n');
    GenFinalSummary(datapath,-1, aTimes);
%     [cyclesection,repsection] = detectcycling(output,walklabel,datapath,-1);   
else
    [peakoutput,indexoutput,cadoutput,speedoutput,stridelenoutput,numofsteps,flag] = walkingparameteranalysis_new(output,para,walksection,40,datapath,trainingsensor_info.sensor_info);
    % generate summary file
    flag = segDataSections(datapath,1);
    
    % detect pedaling and leglifts data
    %[cyclesection,repsection] = detectcycling(output,walklabel,datapath,flag); 
    GenFinalSummary(datapath,flag, aTimes);
    figure;plot(output.data(:,1)-output.data(1,1),output.data(:,2),'r');hold on;
    plot(output.data(:,1)-output.data(1,1),output.data(:,3),'g');
    plot(output.data(:,1)-output.data(1,1),output.data(:,4),'b');
    plot(walklabel,'k.');
    print('-depsc','-tiff','-r300',[datapath '/results' 'result']);
    save([datapath '/results/' 'classificationresult'],'walklabel','NBoutput','label','peakoutput','walklabel2');
    close all; 
end
