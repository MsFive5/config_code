% dailyprocess symmetry calculation routine
% clear all; close all; 
% trainingpath = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/training';
% path = '/home/celia/PAM_DATA/SIRRACT/sampledata/0001/20100915';

function dailyprocesssymmetry(trainingpath,datapath)

sensor_info = MergeProcess('dailyprocess',datapath);
input = load([datapath '/' 'dailyprocessMerge.mat']);
output = correctOrientation(input);

output.data(:,2:7) = output.data(:,2:7)/340;
lefttemplate = load([trainingpath '/' 'leftswingtemplate']);
lefttemplate.data(:,2:7) = lefttemplate.data(:,2:7)/340;
righttemplate = load([trainingpath '/' 'rightswingtemplate'])
righttemplate.data(:,2:7) = righttemplate.data(:,2:7)/340;


if exist([datapath '/' 'walksection.mat']) >0
    load([datapath '/' 'walksection.mat']);
    walksection = walksectionout;
    para = load([trainingpath '/' 'training_para.mat']);
    [indexoutput,cadoutput,speedoutput,stridelenoutput,symmetryoutput,numofsteps,flag] = walkingsymmetryanalysis(input,para.para,walksection,40,datapath,lefttemplate,righttemplate);
else
    template = load([trainingpath '/' 'fullstridetemplate.mat']);
    % use dtw to characterize walksection
    [labelleft,positionleft,stdvalue,distance] = templateMatch2(output.data(:,2:4),template.left);
    [labelright,positionright,stdvalue,distance] = templateMatch2(output.data(:,5:7),template.right);
    [label,walksectiondtw] = combinelabel(labelleft,labelright);

    % use NB to characterize walksection
    trainingstructure = load([trainingpath '/' 'NaiveBayes_training.mat']);
    NBoutput = DailyProcess(output,trainingstructure,trainingpath);

    % combine the result from NB and DTW
    [walksection,walklabel] = combineNBandDTW(output,label,walksectiondtw,NBoutput,datapath);
    para = load([trainingpath '/' 'training_para.mat']);
    [indexoutput,cadoutput,speedoutput,stridelenoutput,symmetryoutput,numofsteps,flag] = walkingsymmetryanalysis(output,para.para,walksection,40,datapath,lefttemplate,righttemplate);    
end
% generate summary file
segDataSections(datapath,2);

% detect pedaling and leglifts data
% [cyclesection,repsection] = detectcycling(output,walklabel,datapath,2);
