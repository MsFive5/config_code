% Testing Process
function output = DailyProcess(input,trainingstructure,trainingpath,sensor_info, configVal)
output = [];
data = input.data;
header = input.header;
addpath(genpath('toolboxes'));


trainingFeatures = cell(length(trainingstructure.training_features),1);
for l=1:length(trainingstructure.training_features)
    trainingFeatures{l} = trainingstructure.training_features{l}.id;
end
availableFeatures = trainingFeatures;

% load([trainingpath '/' 'trainingsensor_info.mat']);
% if strcmp(sensor_info{1}.hemiside,'left ') == 1

if strcmp(sensor_info{1}.hemiside,'1 ') == 0
    SelectedFeatures = [{availableFeatures{10}} {availableFeatures{14}} {availableFeatures{16}} ];
else
    SelectedFeatures = [{availableFeatures{1}} {availableFeatures{5}} {availableFeatures{7}}];    
end

if length(sensor_info) == 1
    if strcmp(sensor_info{1}.sensorName,'1 ') == 1
       % SelectedFeatures = [{availableFeatures{1}} {availableFeatures{4}} {availableFeatures{5}} {availableFeatures{7}}];
        SelectedFeatures = [{availableFeatures{1}} {availableFeatures{5}} {availableFeatures{7}}];
    else
        %SelectedFeatures = [{availableFeatures{10}} {availableFeatures{13}} {availableFeatures{14}} {availableFeatures{16}}]; 
        SelectedFeatures = [{availableFeatures{10}} {availableFeatures{14}} {availableFeatures{16}}];
    end
end

SelectedFeaturesStruc = {};
for n = 1:length(SelectedFeatures)
    tmp.numThreshold = 2;
    tmp.id = SelectedFeatures{n};
    tmp.measure = 1;           
    SelectedFeaturesStruc{n} = tmp;
end

MATData = {};
startN = datenum([input.header{1}.start_date input.header{1}.start_time])*86400;
data(:,1) = data(:,1) + startN;
finalData = data;
MATData{end+1}.data = finalData;
MATData{end}.header = header;

starts = [];
for l=1:length(MATData)
    starts = [starts MATData{l}.data(1,1)];
end
[v,ind] = sort(starts);
MATData = {MATData{ind}};

if(~isempty(MATData))
    data = MATData{1}.data;
end
for l=2:length(MATData)
    data = [data;MATData{l}.data];
end

classes = {};
for l = 1:length(MATData)
    for m=1:length(trainingstructure.training_struct)
        found = 0;
        for n=1:length(classes)
            if(strcmp(classes{n},trainingstructure.training_struct{m}.id))
                found = 1;
            end
        end
        if(~found)
            classes{end+1} = trainingstructure.training_struct{m}.id;
        end
    end
end
    
testingStruct = cell(1,length(classes));
for c = 1:length(classes)
    testingStruct{c}.apriori = 1/length(classes);
end
    

sampleRate = MATData{1}.header{1}.sample_rate;
[classification]=eval(sprintf('%s_test(MATData{1}.header,data,trainingstructure.feature_extractor,trainingstructure.training_features,trainingstructure.training_struct,testingStruct,SelectedFeaturesStruc,sampleRate, configVal)',trainingstructure.classifier));
output.classification = classification;
output.starttime = input.data(1,1);