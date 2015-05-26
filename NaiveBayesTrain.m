% training process
function  sampleRate = NaiveBayesTrain(input,trainingsection,path, configStruc)
trainingstructure = [];
addpath(genpath('toolboxes'));
data = input.data;
header = input.header;
limits.class = 'walk';
limits.region = [];
for n = 1:length(trainingsection)
    if trainingsection(n).valid == 1
        limits.region = [limits.region;input.data(trainingsection(n).start)];
        limits.region = [limits.region;input.data(trainingsection(n).end)];
    end
end
label.limits = limits;
startN = datenum([header{1}.start_date header{1}.start_time])*86400;
label.limits.region = label.limits.region + startN;

data(:,1) = data(:,1) + startN;
MATData.data = data; 
MATData.header = header;
MATData.label = label;

starts = [];
starts = [starts MATData.data(1,1)];
[v,ind] = sort(starts);

        %Find the classes
classes = {};

        found = 0;
        for n=1:length(classes)
            if(strcmp(classes{n},MATData{l}.label.limits.class))
                found = 1;
            end
        end
        if(~found)
             classes{end+1} = MATData.label.limits.class;
        end

trainingStruct = cell(1,length(classes));
 for c = 1:length(classes)
    trainingStruct{c}.id = classes{c};
    trainingStruct{c}.start = [];
    trainingStruct{c}.end = [];
    intervals = [];
            if(strcmp(trainingStruct{c}.id,MATData.label.limits.class))
                intervals = [intervals MATData.label.limits.region];
            end
    trainingStruct{c}.start = intervals(1:2:end);
    trainingStruct{c}.end = intervals(2:2:end);
    trainingStruct{c}.apriori = 1/length(classes);
end
if(~isempty(MATData))
    data = MATData.data;
end
sampleRate = MATData.header{1}.sample_rate;

featuresString = eval('FeatureExtractor_v1_list_features()');
features = cell(length(featuresString),1);
for feat = 1:length(featuresString)
    tmp.id = featuresString{feat};
    tmp.numThreshold = 2;
    tmp.measure = 1;
    features{feat} = tmp;
end
feature_extractor = 'v1';
classifier = 'NaiveBayes';
[training_features,training_struct]=NaiveBayes_train(MATData.data,MATData.header,feature_extractor,features,trainingStruct,sampleRate);
save([path '/' 'NaiveBayes_training.mat'],'training_features','features','training_struct','feature_extractor','classifier');
