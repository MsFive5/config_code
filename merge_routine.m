% merging only routine
function [cyclesection] = merge_routine(datapath,timezone)
cyclesection = [];
sampleRate = 40;

dataLcell = {};
dataRcell = {};
Lcount = 0; 
Rcount = 0;

mergeData = [];
temp = csvread([datapath '/fullmerged.csv']);
mergeData(:, 1:11) = temp(:,1:11);
mergeData(:,12:21) = temp(:, 13:end);

mergeData = padZeros(mergeData);
% need to make the header
% create a fake header here
header{1}.sensorName = 'L';
header{1}.sampleRate = sampleRate;
matlabtime = [];
matlabtime = unix2matlab(mergeData(:,1)');
matlabtime = matlabtime';
startTime = datevec(matlabtime(1));

start_date = [startTime(1)  startTime(2)  startTime(3)];
start_time = [startTime(4) startTime(5) 0];
header{1}.start_date = start_date;
header{1}.start_time = start_time; 
header{1}.sample_rate = sampleRate;
header{1}.timezone = timezone;
headertime = datenum([start_date start_time]);
secArray = (matlabtime' - headertime)*24*60*60;
mergeData(:,1) = secArray(:,end);

header{2} = header{1};

header{2}.sensorName = 'R';

data = mergeData; 
save([datapath '/' 'fullmerge.mat'],'data', 'header');

