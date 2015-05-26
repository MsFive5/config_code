% % training routine
function trainingroutine_new(datapath, configFile)
sampleRate = 40; 
THRESH = 0.1; 
TIMEDIFF = 25;
% config file interpret; added by Celia on 05/04/15
% configFile = [configPath '/configFile.txt'];
configStruc = interpretConfig(configFile);
% sensor_info = MergeProcess('training',datapath);
sensor_info = TrainingInfoInterpret(datapath);
% files = dir([sensor_info{1}.datapath  '*.data']);
files = [];
fileCount = 0; 
for n = 1 : length(sensor_info{1}.files)
    for m = 1 : length(sensor_info)
        fileCount = fileCount + 1; 
        files(fileCount).name = strrep(sensor_info{m}.files{n}, sensor_info{1}.datapath,'');
    end
end
trainingData = {};

count = 0; 
indArray = [];
timeSeq = [];
fullData = [];
for n = 1 : length(files)
    cFile = files(n).name;
    [a, b] = strtok(files(n).name, '_');
    [c, d] = strtok(b, '_');
    if strcmp(c(1), 'L') == 1 % the left sensor
        [timeL, dataL] = interpretDataFile([sensor_info{1}.datapath  cFile]);
    else % the right sensor
        [timeR, dataR] = interpretDataFile([sensor_info{1}.datapath  cFile]);
    end  
    if mod(n, 2) == 0 % merge files with every 2 files
        count = count + 1; 
        % it is risky that if one training file is missing the merge will
        % crash
        newdata = mergeLR(timeL, dataL, timeR, dataR, sampleRate); 
        fullData = newdata;
        % trim off the white space
        data = [newdata(:,1) newdata(:, 2 : 4) newdata(:, 12 : 14)];
%         [newdata, startindex, endindex] = trimWhiteSpace(data, THRESH, sampleRate);
        newdata = data; 
        startindex = 1; 
        endindex = length(data);
        fullData = fullData(startindex : endindex, : );
        trainingData{count}.data = [newdata(:,1) newdata(:,2:end)/2048];
        trainingData{count}.fullData = fullData;
        timeSeq = [timeSeq; newdata(1, 1)];
    end
end
trainingDataSort = {}; 
[a, indArray] = sort(timeSeq);
for n = 1 : length(trainingData)
    trainingDataSort{n}.data = trainingData{indArray(n)}.data;   
    trainingDataSort{n}.fullData = trainingData{indArray(n)}.fullData;
end

trainingData = trainingDataSort;

% pad 0s within data
mergeData = trainingData{1}.data;
mergeFull = trainingData{1}.fullData;
trainingsection(1).start = 1; 
trainingsection(1).end = length(mergeData);

for n = 2 : length(trainingData)
    cStart = trainingData{n}.data(end, 1);
    mergetime = mergeData(end, 1);
    padArraylen = round((cStart - mergetime)/TIMEDIFF);
    mergeData = [mergeData; zeros(padArraylen, size(mergeData, 2)); trainingData{n}.data];
    mergeFull = [mergeFull; zeros(padArraylen, size(fullData, 2)); trainingData{n}.fullData];
    mergeData(:, 1) = mergeData(1, 1) : TIMEDIFF : (length(mergeData) - 1) * TIMEDIFF + mergeData(1, 1); 
    mergeFull(:, 1) = mergeData(:, 1);
    trainingsection(n).start = trainingsection(n - 1).end + padArraylen + 1; 
    trainingsection(n).end = length(mergeData);
    trainingsection(n).valid = 1; 
end
trainingsection(1).valid = 1;
% create a fake header here
header{1}.sensorName = 'L';
header{1}.sampleRate = sampleRate;
% get sensor time
for n = 1:length(mergeData)
    matlabtime(n) = unix2matlab(mergeData(n,1));
end

startTime = datevec(matlabtime(1));

start_date = [startTime(1)  startTime(2)  startTime(3)];
start_time = [startTime(4) startTime(5) 0];
header{1}.start_date = start_date;
header{1}.start_time = start_time; 
header{1}.sample_rate = sampleRate;
headertime = datenum([start_date start_time]);
secArray = (matlabtime' - headertime) * 86400;
mergeData(:,1) = secArray(:,end);

header{2} = header{1};

header{2}.sensorName = 'R';

% needs to be read from the txt file parsing
% sensor_info{1}.boutlength = '25';
% sensor_info{1}.hemiside = '1 ';
save([datapath '/' 'trainingsensor_info.mat'],'sensor_info');
% input = load([datapath '/' 'trainingMerge.mat']);
% input.data(:,2:7) = input.data(:,2:7)/340;
% 16 bit with +/-16g   2048 = 2^12/32;
% input.data(:,2:7) = input.data(:,2:7)/2048;

% template = load('signature');
% template.data(:,2:4) = template.data(:,2:4)/340;
% check the existence of mannual delimit
% if exist([datapath '/' 'trainingsectiondelimit.mat']) == 2
%     load([datapath '/' 'trainingsectiondelimit.mat']);
% else
%     numofboughts = str2num(sensor_info{1}.numofbout);
%     [trainingsection] = delimitTraining2(input,template,15,numofboughts,datapath);
% end
% if length(trainingsection) == 0
%     return;
% else 

% sensor orientation correction
mergeC = mergeData;
% orientation correction
if strcmp(configStruc{1}.value, 'True')
    mergeC(:,2) = mergeData(:,4)*(-1);
    mergeC(:,3) = mergeData(:,2);
    mergeC(:,4) = mergeData(:,3);

    mergeC(:,5) = mergeData(:,7)*(-1);
    mergeC(:,6) = mergeData(:,5);
    mergeC(:,7) = mergeData(:,6);
   
end

input.data = mergeData;
input.header = header; 
data = input.data; 
data = mergeFull;
data = mergeData;
data = mergeC; 
header = input.header
save([datapath '/' 'trainingMerge.mat'],'data', 'header');
input.data = mergeC;
    samplerate = NaiveBayesTrain(input, trainingsection, datapath);
    [para,trainingsection,vector1,vector2] = getWalkingPara_new(input,trainingsection,sensor_info{1},samplerate,datapath);
    save([datapath '/' 'trainingsection.mat'],'trainingsection');
% end