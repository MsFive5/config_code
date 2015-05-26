function [features,training_struct]=NaiveBayes_train(data,...
                                                     header,...
                                                     feature_extractor,...
                                                     features,...
                                                     training_struct,...
                                                     samplerate)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Choose the features to be trained on.
    %
    % Feature (SELECT WHICH FEATURES ARE IN THE TEST)
    % These features will be evaluated.
    %
    % For now, we will calcualte the values of ALL the feaures.
    % but to actually convert them to the 3 levels, the choice
    % is made by setting measure==1;
    %
    % 'EXAMPLE OF FEATURE CELL'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    tmp = [];
    measure = [];
    originalFeatures = {};
    for l=1:length(header)
        for k=1:length(features)
            originalFeatures{end+1} = features{k};
            originalFeatures{end}.id = [header{l}.sensorName '_' features{k}.id];
        end
    end
    features = originalFeatures;
    for l=1:length(features)
        if(features{l}.measure)
            tmp = [];
            tmp.id = features{l}.id;
            tmp.link = l;
            measure{end+1} = tmp;
        end
     end
       
    idealdelta = 1/samplerate;
    allmatrix=[];
    write = 0;

    time = data(:,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % METS 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mets(1:8) = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function to consolidate the start and end of all classes.
    %
    % NOTE: THERE MUST BE A FUNCTION TO DETECT OVERLAP OF CLASSES!!!
    %       Should this be done in the user interface or somewhere else?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(~isempty(training_struct))
        label_state = sse_consolidate_label(training_struct);
    else
        label_state = [];
    end
    
    %Accelerometer 0 acceleration readings. These get determined dynamically
    %whenever the accelerometer determined to be at rest
    % ax_rest(1) = 0;
    % ay_rest(1) = 0;
    % az_rest(1) = 0;

    %Array to hold classification settings. Classification key is:
    %-> To be based on training_struct
    % 0 -- At rest
    % 1 -- Walking
    % 2 -- Running
    % 3 -- Walking Down Stairs
    % 4 -- Walking Up Stairs
    % classification(1) = 0;

    %Change the raw data into g-force
    %Low gain: gforce = (counts - 8192)*15/16384
    %High gain: gforce = (counts - 8192)*5/16384walkingfast.corr.med  = 0
    % ax = (ax-8192).*15./16384;0000         0    0.0000
    % ay = (ay-8192).*15./16384;
    % az = (az-8192).*15./16384;4

    feature_extractor_function = ['FeatureExtractor_' feature_extractor ...
                                  '(originalFeatures, header, processed_data);'];
                              
    %Loop through the time and determine the classification in 1 second intervals
    count = 0;
    buffercount=0;
    winSize = 4;
    training_record = [];
    
    for x = time(1):1:max(time)-1
        count = count + 1;
        classification(count) = 0; %XXX TSK 1 OR 0???

        %Find the samples corresponding to the start/end of the second interval
    %     periodstart = max(find(time <= x));
    %     periodend = max(find(time <= x+1));
        periodstart = find(time <= x, 1, 'last' );
        periodend   = find(time <= x+1, 1, 'last' );    
        startarray(count) = periodstart;
        endarray(count) = periodend;

        %make winSize second window intervals
        if(count >=  winSize)
            if(mod(count,2) == 0)
                % Find the label of the current state.
                class_num = sse_find_class(x,label_state);

                frame_vertical = data(startarray(count-3):periodend,((1:length(header))-1)*3+2);
                frame_horizontal = data(startarray(count-3):periodend,((1:length(header))-1)*3+3);
                frame_tangent = data(startarray(count-3):periodend,((1:length(header))-1)*3+4);
                % Preprocessing of data.

                %Frame is declared as being active. Make the 4 second window
                %of data, then determine the classification by considering
                %frequency, peak to peak magnitude, and axial correlation
                %between the horizontal and vertical axes
%                 [fixed_vertical,fixed_horizontal,fixed_tangent,fixedtime] = ...
%                     fixdatanew( frame_vertical,frame_horizontal,frame_tangent, ...
%                                 time,startarray(count-3),count,idealdelta);  

                 % Measure the features to be used.
                 fixed_vertical = frame_vertical;
                 fixed_horizontal = frame_horizontal;
                 fixed_tangent = frame_tangent;
                 
                 processed_data.vertical    = fixed_vertical;
                 processed_data.horizontal  = fixed_horizontal;
                 processed_data.tangent     = fixed_tangent;
                 processed_data.periodstart = periodstart;
                 processed_data.periodend   = periodend;
                 [val_vec, val_struct,features] = eval(feature_extractor_function);

                 tmp = val_vec(:);
                 tmp = [class_num; tmp];
                 training_record(:,end+1) = tmp;
            end
        end
    end
    
    
    % Determine the threshold for each feature.
    for k=1:length(features)
       idx = k+1;
       tmp = training_record(k+1,:);
       max_feature_val = max( tmp );
       min_feature_val = min( tmp );
       rge_feature_val = max_feature_val - min_feature_val;
       num_freature_thres = features{k}.numThreshold;
       lvl_feature_val = rge_feature_val/(num_freature_thres+1);
       features{k}.threshold = min_feature_val + [1:num_freature_thres]*lvl_feature_val;
       features{k}.prob      = zeros(length(training_struct),num_freature_thres+1);
    end

    % For each class, determine the prob.
    for k=1:length(training_struct)
        idx = find(training_record(1,:)==k);
        tmpData = training_record(2:end,idx);    
        for p=1:length(features)
            cntVec = zeros(1, features{p}.numThreshold+1);
            feature_thres = features{p}.threshold;
            for r=1:length(feature_thres)
                cnt = length(find(tmpData(p,:)<=feature_thres(r)));
                cntVec(r) = cnt;
            end
            tmpTot = length(tmpData(p,:));
            cntVec(r+1) = tmpTot;
            cntVec(2:end) = cntVec(2:end)-cntVec(1:end-1);
            cntVec = cntVec ./ tmpTot;
            features{p}.prob(k,:) = cntVec;
        end
    end
    
    for k=1:length(training_struct)
        training_struct{k}.feat = training_record(2:end,training_record(1,:)==k)';
    end
    
    for k=1:length(training_struct)
        training_struct{k}.mu = mean(training_struct{k}.feat,1);
        training_struct{k}.sigma = zeros(size(training_struct{k}.feat,2));
        for l=1:size(training_struct{k}.feat,1)
            training_struct{k}.sigma = training_struct{k}.sigma+...
                                ((training_struct{k}.feat(l,:)-training_struct{k}.mu)'*...
                                 (training_struct{k}.feat(l,:)-training_struct{k}.mu))/...
                                size(training_struct{k}.feat,1);
        end
        training_struct{k}.sigma = diag(diag(training_struct{k}.sigma));
        if(det(training_struct{k}.sigma)==0)
%             training_struct{k}.sigma = training_struct{k}.sigma + diag(ones(length(training_struct{k}.sigma),1))*1e-3;
            training_struct{k}.sigma = training_struct{k}.sigma + 1e-3*diag(ones(length(training_struct{k}.sigma),1))*trace(training_struct{k}.sigma)/length(training_struct{k}.sigma);
            fprintf('WARNING! Singular covariance matrix for class %d, perturbation of %e has been added to the diagonal.\n',k,1e-3*trace(training_struct{k}.sigma)/length(training_struct{k}.sigma));
        end
    end
    
    
