% % training routine
function trainingroutine(datapath)
% path = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/training';
if exist([datapath '/' 'trainingMerge.mat'])>0
%     sensor_info = TrainingInfoInterpret(datapath);
    load([datapath '/' 'trainingsensor_info.mat']);
else
    sensor_info = MergeProcess('training',datapath);    
end

input = load([datapath '/' 'trainingMerge.mat']);
input.data(:,2:7) = input.data(:,2:7)/340;

template = load('signature');
template.data(:,2:4) = template.data(:,2:4)/340;
% check the existence of mannual delimit
if exist([datapath '/' 'trainingsectiondelimit.mat']) == 2
    load([datapath '/' 'trainingsectiondelimit.mat']);
else
    numofboughts = str2num(sensor_info{1}.numofbout);
    [trainingsection] = delimitTraining2(input,template,15,numofboughts,datapath);
end
if length(trainingsection) == 0
    return;
else   
    samplerate = NaiveBayesTrain(input,trainingsection,datapath);
    [para,trainingsection,vector1,vector2] = getWalkingPara(input,trainingsection,sensor_info{1},samplerate,datapath);
    save([datapath '/' 'trainingsection.mat'],'trainingsection');
end
