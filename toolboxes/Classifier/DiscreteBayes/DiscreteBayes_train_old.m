function [features,training_struct]=DiscreteBayes_train(data,...
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
    ax = data(:,2);
    ay = data(:,3);
    az = data(:,4);
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

    ax=ax./340;
    ay=ay./340;
    az=az./340;

    feature_extractor_function = ['FeatureExtractor_' feature_extractor ...
                                  '(features, processed_data);'];
                              
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

                % Preprocessing of data.
                frame_vertical   = ax(startarray(count-3):periodend);
                frame_horizontal = ay(startarray(count-3):periodend);
                frame_tangent    = az(startarray(count-3):periodend);

                %Frame is declared as being active. Make the 4 second window
                %of data, then determine the classification by considering
                %frequency, peak to peak magnitude, and axial correlation
                %between the horizontal and vertical axes
                [fixed_vertical,fixed_horizontal,fixed_tangent,fixedtime] = ...
                    fixdatanew( frame_vertical,frame_horizontal,frame_tangent,...
                                time,startarray(count-3),count,idealdelta);  

                 % Measure the features to be used.
                 processed_data.vertical    = fixed_vertical;
                 processed_data.horizontal  = fixed_horizontal;
                 processed_data.tangent     = fixed_tangent;
                 processed_data.periodstart = periodstart;
                 processed_data.periodend   = periodend;
                 [val_vec, val_struct] = eval(feature_extractor_function);

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
    
    