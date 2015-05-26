%testing routine
% clear all; close all; 
function [cyclesection] = dailyprocessroutine(trainingpath,datapath)
% trainingpath = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/training';
% path = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/20100915';
% timestart = tic;
cyclesection = [];

sensor_info = MergeProcess('dailyprocess',datapath);
if exist([trainingpath '/' 'fullstridetemplate.mat'])==0
    return;
else
end

template = load([trainingpath '/' 'fullstridetemplate.mat']);
trainingsensor_info= load([trainingpath '/trainingsensor_info.mat']);
input = load([datapath '/' 'dailyprocessMerge.mat']);
for n = 1:length(sensor_info)
    sensor_info{n}.hemiside = trainingsensor_info.sensor_info{1}.hemiside;
end

% no data 
if length(input.data) ==0
    return;
end
output = correctOrientation(input);
if length(output.data) == 0
    return;
end
output.data(:,2:7) = output.data(:,2:7)/340;

% use dtw to characterize walksection
[labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.left);
[labelright,positionright,stdvalue,distance] = templateMatch2(output.data(:,5:7),template.right);
[label,walksectiondtw] = combinelabel2(labelleft,labelright);

% use NB to characterize walksection
trainingstructure = load([trainingpath '/' 'NaiveBayes_training.mat']);
NBoutput = DailyProcess(output,trainingstructure,trainingpath,sensor_info);

% combine the result from NB and DTW
walklabel = generatewalklabel(output,label,walksectiondtw,NBoutput,datapath);
if length(find(walklabel))<1
    return;
end
[walksection] = combineNBandDTW2(output,label,walksectiondtw,NBoutput,datapath,walklabel);
% walklabel2 = post_filter(walklabel,output);
save([datapath '/' 'walklabel.mat'],'walklabel');

% generate real-time file

para = load([trainingpath '/' 'training_para.mat']);
if length(walksection) == 0
    savefilename = [datapath '/' 'dailyprocess_','realtimeresultwithoutratio']; 
    fid = fopen(savefilename,'w');
    fprintf(fid,'number of steps is 0, total distance is 0.0\n');
    GenFinalSummary(datapath,-1);
%     [cyclesection,repsection] = detectcycling(output,walklabel,datapath,-1);   
else
    [peakoutput,indexoutput,cadoutput,speedoutput,stridelenoutput,numofsteps,flag] = walkingparameteranalysis(output,para,walksection,40,datapath);
    % generate summary file
    flag = segDataSections(datapath,1);
    
    % detect pedaling and leglifts data
    %[cyclesection,repsection] = detectcycling(output,walklabel,datapath,flag); 
    GenFinalSummary(datapath,flag);
    figure;plot(output.data(:,1)-output.data(1,1),output.data(:,2),'r');hold on;
    plot(output.data(:,1)-output.data(1,1),output.data(:,3),'g');
    plot(output.data(:,1)-output.data(1,1),output.data(:,4),'b');
    plot(walklabel,'k.');
    print('-depsc','-tiff','-r300',[datapath '/' 'result']);
    save([datapath '/' 'classificationresult'],'walklabel','NBoutput','label','peakoutput');
    close all; 
end
