function [classification,correct]=DiscreteBayes_test(header,...
                                                     data,...
                                                     feature_extractor,...
                                                     training_features,...
                                                     training_struct,...
                                                     testing_struct,...
                                                     measure,...
                                                     samplerate)
 
    %class level
    % %1 walking; 3 downstairs; 4 upstairs; 6 hst4; 5 hst7;
    % % 0 not in use; -1 sitting; -2 standing;
    % 0 sitting; 1 standing; 2 unstable standing; 
    % 3 food feeding; 4 combing hair; 
    % 5 walk slow; 6 walk fast; 7 downstairs; 8 upstairs
    %Parameters
    idealdelta = 1/samplerate;
    allmatrix=[];
    
    time = data(:,1);
    
%     time = data(:,1)-data(1,1);

%     ax = data(:,2);
%     ay = data(:,3);
%     az = data(:,4);
    % fixeddata = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % METS 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    mets(1:8) = 0;

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
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load features form training
    % assume user wants to select what features are used to 
    % test the data with.
    %
    % Input is measure cell.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %XXX assume user can set what measure to use.


    for k=1:length(measure)
        measure{k}.link = 0;
        for p=1:length(training_features)
            if(strcmp(training_features{p}.id,measure{k}.id)==1)
                measure{k}.link = p; 
            end
        end
        if(measure{k}.link==0)
            fprintf('ERROR!!! Selected measure not in calcaulated training_features list\n');
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % All user assignment should stop right here.
    % The rest of the code should be automated.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function to consolidate the start and end of all classes.
    %
    % NOTE: THERE MUST BE A FUNCTION TO DETECT OVERLAP OF CLASSES!!!
    %       Should this be done in the user interface or somewhere else?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(~isempty(testing_struct))
        label_state = sse_consolidate_label_test(testing_struct,training_struct);
    else
        label_state = [];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is left here as the plotting commands uses walkslowsets, etc..
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %Loop through the events to determine the ranges
    % for walkslowsets = 1:length(walkslowstart)  
    %     range(walkslowsets).walkslow = walkslowstart(walkslowsets):walkslowend(walkslowsets);
    % end
    % 
    % for walkfastsets = 1:length(walkfaststart)
    %     range(walkfastsets).walkfast = walkfaststart(walkfastsets):walkfastend(walkfastsets);
    % end
    % for upsets = 1:length(upstart)
    %     range(upsets).up = upstart(upsets):upend(upsets);
    % end
    % for downsets = 1:length(downstart)
    %     range(downsets).down = downstart(downsets):downend(downsets);
    % end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function to init records based on features
    %   record{class_num, feature_num} = [low med high]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    record = sse_init_record_v2(testing_struct,training_features);

    %Accelerometer 0 acceleration readings. These get determined dynamically
    %whenever the accelerometer determined to be at rest
    % ax_rest(1) = 0;
    % ay_rest(1) = 0;
    % az_rest(1) = 0;

    %Array to hold classification settings. Classification key is:
    %-> To be based on testing_struct
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

    %Loop through the time and determine the classification in 1 second intervals
    count = 0;
    buffercount=0;
    winSize = 4;
    training_record = [];
    feature_extractor_function = ['FeatureExtractor_' feature_extractor ...
                                  '(measure, header, processed_data);'];
  
    for x = time(1):1:max(time)-1
        count = count + 1;
        classification(count) = 0; %XXX TSK 1 OR 0???

        %Find the samples corresponding to the start/end of the second interval
        periodstart = find(time <= x, 1, 'last' );
        periodend   = find(time <= x+1, 1, 'last' );    
        startarray(count) = periodstart;
        endarray(count) = periodend;

        %make winSize second window intervals
        if(count >=  winSize)
            if(mod(count,2) == 0)
                % Find the label of the current state.
                class_num = sse_find_class(x,label_state);
                trueClassification(count) = class_num;

                % Preprocessing of data.
                frame_vertical = data(startarray(count-3):periodend,((1:length(header))-1)*3+2)/340;
                frame_horizontal = data(startarray(count-3):periodend,((1:length(header))-1)*3+3)/340;
                frame_tangent = data(startarray(count-3):periodend,((1:length(header))-1)*3+4)/340;

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
                 
                 %create feature vector
                 [val_vec, val_struct,features] = eval(feature_extractor_function);

                 %find most likely class
				 maxclass = 0;
                 % Calculate the prob of F=f_value for each class.
                 [probList,record]=sse_calculate_prob_of_feature_in_each_class_v2( ...
                       measure, training_features, testing_struct, record, class_num, val_vec);
                 % Calculate the prob of each class based on the f_values
                 testvector = sse_calculate_prob_of_each_class(probList, testing_struct);
                 allmatrix = [allmatrix;testvector];
                 maxclass = find(testvector==max(testvector));
                 maxval = max(testvector);
                 
                 %log the greatest likelihoods
                 likelihoods(count) = maxval(1);
                 

                 
                 timedelta = time(periodend) - time(periodstart);
                 classification(count) = maxclass(1);

            else
                    classification(count) = classification(count-1);
                    trueClassification(count) = trueClassification(count-1);
                    likelihoods(count) = likelihoods(count-1);
            end
        end
    end
    

    correct = zeros(1,count);
    for k=1:size(label_state,2)     
        tmpStart = label_state(1,k)-data(1,1);
        tmpEnd = label_state(2,k)-data(1,1);
        tmpClass = label_state(3,k);
        correct( ceil(tmpStart):floor(tmpEnd) ) = tmpClass;
    end

    
