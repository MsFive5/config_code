% dailyprocesssingle.m
function [cyclesection] = dailyprocesssingle(trainingpath,datapath)
template = load([trainingpath '/' 'fullstridetemplate.mat']);
trainingsensor_info= load([trainingpath '/trainingsensor_info.mat']);
sensor_info = MergeProcess('dailyprocess',datapath);
for n = 1:length(sensor_info)
    sensor_info{n}.hemiside = trainingsensor_info.sensor_info{1}.hemiside;
end
input = load([datapath '/' 'dailyprocessMerge.mat']);
output = correctOrientationsingle(input);

output.data(:,2:4) = output.data(:,2:4)/340;

% use dtw to characterize walksection
if strcmp(output.header{1}.sensorName,'left')==1
    [labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.left);   
else
    [labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.right);    
end
% [labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.left);
% [labelright,positionright,stdvalue,distance] = templateMatch2(output.data(:,5:7),template.right);
[label,walksectiondtw] = combinelabel(labelleft,labelleft);

% use NB to characterize walksection
trainingstructure = load([trainingpath '/' 'NaiveBayes_training.mat']);
NBoutput = DailyProcess(output,trainingstructure,trainingpath,sensor_info);

% combine the result from NB and DTW
[walksection,walklabel] = combineNBandDTW(output,label,walksectiondtw,NBoutput,datapath);
if length(find(walklabel))<1
    fid = fopen([datapath '/' 'datablank'],'w');
    fclose(fid);
    return;
end
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
    [indexoutput,cadoutput,speedoutput,stridelenoutput,numofsteps,flag] = walkingparameteranalysissingle(output,para,walksection,40,datapath);
    % generate summary file
    segDataSections(datapath,1);
    % detect pedaling and leglifts data
    GenFinalSummary(datapath,flag);
    figure;plot(output.data(:,1)-output.data(1,1),output.data(:,2),'r');hold on;
    plot(output.data(:,1)-output.data(1,1),output.data(:,3),'g');
    plot(output.data(:,1)-output.data(1,1),output.data(:,4),'b');
    plot(walklabel,'k.');
    print('-depsc','-tiff','-r300',[datapath '/' 'result']);
    close all;    
    
end


