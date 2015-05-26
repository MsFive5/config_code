function [classification,correct]=NaiveBayes_test(header,...
                                                  data,...
                                                  feature_extractor,...
                                                  training_features,...
                                                  training_struct,...
                                                  testing_struct,...
                                                  measure,...
                                                  samplerate, ...
                                                    configVal)
 
    %class level
    % %1 walking; 3 downstairs; 4 upstairs; 6 hst4; 5 hst7;
    % % 0 not in use; -1 sitting; -2 standing;
    % 0 sitting; 1 standing; 2 unstable standing; 
    % 3 food feeding; 4 combing hair; 
    % 5 walk slow; 6 walk fast; 7 downstairs; 8 upstairs
    %Parameters
    
    % for test purpose should delte later by Celia 05/04/15
    disp(configVal);
    
    
    classification = [];
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
%     if(~isempty(testing_struct))
%         label_state = sse_consolidate_label_test(testing_struct,training_struct);
%     else
%         label_state = [];
%     end

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
    winSize = 2;
    training_record = [];
    feature_extractor_function = ['FeatureExtractor_' feature_extractor ...
                                  '(measure, header, processed_data);'];
	TotalClasses = length(training_struct);
    train = [];
    labels = [];
    chosenFeatures = zeros(length(measure),1);
    for l=1:length(measure)
        for f=1:length(training_features)
            if(strcmp(measure{l}.id,training_features{f}.id))
                chosenFeatures(l) = f;
            end
        end
    end
    for l=1:TotalClasses
        train = [train;training_struct{l}.feat];
        labels = [labels;ones(size(training_struct{l}.feat,1),1)*l];
        training_struct{l}.invSigma = inv(training_struct{l}.sigma(chosenFeatures,chosenFeatures));
    end
    
    %compute thresholds
    thresholds = zeros(TotalClasses,1);
    thresholds_old = thresholds;
    mus = zeros(TotalClasses,1);
%     vs = zeros(TotalClasses,1);    
%     nintyfifthPercentile = qfuncinv(0.95);
%     const = sqrt(length(chosenFeatures)/2)*(nintyfifthPercentile-sqrt(length(chosenFeatures)/2));
%     for l=1:TotalClasses
%         thresholds_old(l) = const-1/2*log(det(training_struct{l}.sigma(chosenFeatures,chosenFeatures)));
%         mus(l) = -log(sqrt(det(training_struct{l}.sigma(chosenFeatures,chosenFeatures))))-length(chosenFeatures)/2;
% %         vs(l) = log(sqrt(det(training_struct{l}.sigma(chosenFeatures,chosenFeatures))))*length(chosenFeatures)+(log(sqrt(det(training_struct{l}.sigma(chosenFeatures,chosenFeatures)))))^2+length(chosenFeatures)/2+1/4*length(chosenFeatures)^2-mus(l)^2;
%         vs(l) = length(chosenFeatures)/2;
%     end

    nintyfifthPercentile = chi2inv(0.95,length(chosenFeatures));
    for l=1:TotalClasses
%         thresholds_old(l) = sqrt(vs(l))*qfuncinv(0.95)+mus(l);
        logdetTerm = -1/2*log(det(training_struct{l}.sigma(chosenFeatures,chosenFeatures)));
        thresholds(l) = logdetTerm - nintyfifthPercentile/2;
        mus(l) = logdetTerm - length(chosenFeatures)/2;
    end
    
%     for l=1:TotalClasses
%         thresholds(l) = sqrt(vs(l))*nintyfifthPercentile+mus(l);
%     end
    
    unknownThreshold = min(thresholds);
    
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
            %if(mod(count,2) == 0)
                % Find the label of the current state.
%                 class_num = sse_find_class(x,label_state);
%                 trueClassification(count) = class_num;

                % Preprocessing of data.
                frame_vertical = data(startarray(count-1):periodend,((1:length(header))-1)*3+2);
                frame_horizontal = data(startarray(count-1):periodend,((1:length(header))-1)*3+3);
                frame_tangent = data(startarray(count-1):periodend,((1:length(header))-1)*3+4);

                %Frame is declared as being active. Make the 4 second window
                %of data, then determine the classification by considering
                %frequency, peak to peak magnitude, and axial correlation
                %between the horizontal and vertical axes
                [fixed_vertical,fixed_horizontal,fixed_tangent,fixedtime] = ...
                    fixdatanew( frame_vertical,frame_horizontal,frame_tangent,...
                                time,startarray(count-1),count,idealdelta);  

                 % Measure the features to be used.
                 processed_data.vertical    = fixed_vertical;
                 processed_data.horizontal  = fixed_horizontal;
                 processed_data.tangent     = fixed_tangent;
%                  processed_data.vertical    = frame_vertical;
%                  processed_data.horizontal  = frame_horizontal;
%                  processed_data.tangent     = frame_tangent;
                 
                 processed_data.periodstart = periodstart;
                 processed_data.periodend   = periodend;


                 
                 %create feature vector
                 [val_vec, val_struct,features] = eval(feature_extractor_function);

                 %find most likely class
				 maxclass = 0;
                 maxlikelihood = -inf;
                 for currClass = 1:TotalClasses
                     like = -1/2*(val_vec-training_struct{currClass}.mu(chosenFeatures))*(training_struct{currClass}.invSigma*((val_vec-training_struct{currClass}.mu(chosenFeatures))'))-log(sqrt(det(training_struct{currClass}.sigma(chosenFeatures,chosenFeatures))));
                     if(like > maxlikelihood)
                         maxlikelihood = like;
                         maxclass = currClass;
                     end
                 end
                 %log the greatest likelihoods
                 likelihoods(count) = maxlikelihood;
                 
                 %if the maximum likelihood ratio was too low (probably an
                 %unknown class)
                 if(maxlikelihood < unknownThreshold)
                     maxclass = 0;
                 end
                 
                 timedelta = time(periodend) - time(periodstart);
                 classification(count) = maxclass(1);

%                  if (std(fixed_vertical(:,1)) + std(fixed_horizontal(:,1)) + std(fixed_tangent(:,1)))< 0.2  ||...
%                          (std(fixed_vertical(:,2)) + std(fixed_horizontal(:,2)) + std(fixed_tangent(:,2)))< 0.2 % temporary patch
%                      classification(count) = 0;                                          % temporary patch
%                  end                                                                     % temporary patch
%                  
                 fixed_vertical(:,1) = fixed_vertical(:,1) - mean(fixed_vertical(:,1));
                 fixed_horizontal(:,1) = fixed_horizontal(:,1) - mean(fixed_horizontal(:,1));
                 fixed_tangent(:,1) = fixed_tangent(:,1) - mean(fixed_tangent(:,1));
                 
                 fixed_vertical(:,2) = fixed_vertical(:,2) - mean(fixed_vertical(:,2));
                 fixed_horizontal(:,2) = fixed_horizontal(:,2) - mean(fixed_horizontal(:,2));
                 fixed_tangent(:,2) = fixed_tangent(:,2) - mean(fixed_tangent(:,2));
                 leftVal = sum(fixed_vertical(:,1).^2) + sum(fixed_horizontal(:,1).^2) + sum(fixed_tangent(:,1).^2);
                 rightVal = sum(fixed_vertical(:,2).^2) + sum(fixed_horizontal(:,2).^2) + sum(fixed_tangent(:,2).^2);
                  if (sqrt(leftVal)< configVal  || sqrt(rightVal) < configVal) % temporary patch
                     classification(count) = 0;                                          % temporary patch
                 end                       
%             else
%                     classification(count) = classification(count-1);
%                     trueClassification(count) = trueClassification(count-1);
%                     likelihoods(count) = likelihoods(count-1);
%             end
        end
    end
    
%     classification
%     correct = zeros(1,count);
%     for k=1:size(label_state,2)     
%         tmpStart = label_state(1,k)-data(1,1);
%         tmpEnd = label_state(2,k)-data(1,1);
%         tmpClass = label_state(3,k);
%         correct( ceil(tmpStart):floor(tmpEnd) ) = tmpClass;
%     end
% 
%     
