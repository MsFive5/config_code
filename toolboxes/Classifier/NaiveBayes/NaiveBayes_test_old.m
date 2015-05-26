function [classification]=NaiveBayes_test(header,...
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
    winSize = 4;
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
%         labels = [labels;ones(size(training_struct{l}.feat,1),1)*l];
        training_struct{l}.invSigma = inv(training_struct{l}.sigma(chosenFeatures,chosenFeatures));
    end
    
    %compute thresholds
    thresholds = zeros(TotalClasses,1);
    thresholds_old = thresholds;
    mus = zeros(TotalClasses,1);

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

    
%% matrix change    
    wl = 4*samplerate; 
    ws = samplerate; 
    nz = fix((length(data)-wl)/ws)+1;
    c1=(1:wl)';
    cnz=repmat(c1,1,nz); % vertical vector 1:wl repeated horizontally
    l1=0:ws:(nz-1)*ws;
    lnz=repmat(l1, wl,1); % horizontal vector spaced by ws repeated vertically
    indexmatrix = cnz+ lnz;
    
    classification = zeros(1,nz);
    
    for n = 2:size(data,2)
        if mod((n-2),3) == 0 % x data
            numind = (n-2)/3+1;
            datax = data(:,n);
            vertical(:,:,numind) = datax(indexmatrix);
        elseif mod((n-3),3) == 0 % y data
            numind = (n-3)/3+1;
            datay = data(:,n);
            horizontal(:,:,numind) = datay(indexmatrix);
        elseif mod((n-4),3) == 0 % z data
            numind = (n-4)/3+1;
            dataz = data(:,n);
            tangent(:,:,numind) = dataz(indexmatrix);
        end
    end
    numofsensor = length(header);
    
    indarray = {};
    for n = 1:numofsensor
        processed_data.vertical    = vertical(:,:,n);
        processed_data.horizontal  = horizontal(:,:,n);
        processed_data.tangent     = tangent(:,:,numind);  
        stdarray = std(processed_data.vertical(1:wl,:)) + std(processed_data.horizontal(1:wl,:)) + std(processed_data.tangent(1:wl,:));
        currentindex = find(stdarray>0);  % those with really small std values are supposed to be non-walking related activitiess
        indarraycell{n} = currentindex;
    end
    
   % indarray = unique(indarray);
   indarray = indarraycell{1};
   if numofsensor>1    
       for n = 2:numofsensor
           indarray = intersect(indarraycell{n},indarray);
       end
   end
    
    processed_data.vertical = [];
    processed_data.horizontal = [];
    processed_data.tangent = [];
    verticaldata = [];
    horizontaldata = [];
    tangentdata = [];
    for n = 1:length(indarray) % this for is inevitable
        if (n>1) && (mod(n,2) == 1)
            classification(indarray(n)) = classification(indarray(n)-1);
        end
        verticaldata = [];
        horizontaldata = [];
        tangentdata = [];
        for m = 1:numofsensor
            verticaldata = [verticaldata vertical(:,indarray(n),m)];
            horizontaldata = [horizontaldata horizontal(:,indarray(n),m)];
            tangentdata = [tangentdata tangent(:,indarray(n),m)];
%             processed_data.vertical = [processed_data.vertical vertical(:,indarray(n),m)];
%             processed_data.horizontal = [processed_data.vertical horizontal(:,indarray(n),m)];
%             processed_data.tangent = [processed_data.tangent tangent(:,indarray(n),m)];
        end
        processed_data.vertical = verticaldata; %x
        processed_data.horizontal = horizontaldata;%y
        processed_data.tangent = tangentdata;%z        
        startindex = indexmatrix(121,indarray(n));
        endindex = indexmatrix(160,indarray(n));
        processed_data.periodstart = startindex;
        processed_data.periodend = endindex;    
        [val_vec, val_struct,features] = eval(feature_extractor_function);
        maxclass = 0;
        maxlikelihood = -inf;
        for currClass = 1:TotalClasses
            like = -1/2*(val_vec-training_struct{currClass}.mu(chosenFeatures))*(training_struct{currClass}.invSigma*((val_vec-training_struct{currClass}.mu(chosenFeatures))'))-log(sqrt(det(training_struct{currClass}.sigma(chosenFeatures,chosenFeatures))));
            if(like > maxlikelihood)
                maxlikelihood = like;
                maxclass = currClass;
            end
        end

        likelihoods(indarray(n)) = maxlikelihood;

        if(maxlikelihood < unknownThreshold)
            maxclass = 0;
        end
        selfcorr = 0;         
%         timedelta = time(processed_data.periodend) - time(processed_data.periodstart);
        if corr2(processed_data.horizontal(:,1),processed_data.vertical(:,1))>0.7||...
  corr2(processed_data.horizontal(:,1),processed_data.tangent(:,1))>0.7||...
  corr2(processed_data.horizontal(:,2),processed_data.vertical(:,2))>0.7||...
  corr2(processed_data.horizontal(:,2),processed_data.tangent(:,2))>0.7
            selfcorr = 1;
        end
        classification(indarray(n)) = maxclass(1); 
        if length(header)>1
            if corr2(processed_data.horizontal(:,1),processed_data.horizontal(:,2))>0.5 ||selfcorr == 1
                classification(indarray(n)) = 0;
            end
        end
    end
% matrix change end

%     for x = time(1):1:max(time)-1
%         count = count + 1;
%         classification(count) = 0; %XXX TSK 1 OR 0???
% 
%         %Find the samples corresponding to the start/end of the second interval
%         periodstart = find(time <= x, 1, 'last' );
%         periodend   = find(time <= x+1, 1, 'last' );    
%         startarray(count) = periodstart;
%         endarray(count) = periodend;
% 
%         %make winSize second window intervals
%         if(count >=  winSize)
%             if(mod(count,2) == 0)
%                 % Find the label of the current state.
% %                 class_num = sse_find_class(x,label_state);
% %                 trueClassification(count) = class_num;
% 
%                 % Preprocessing of data.
%                 frame_vertical = data(startarray(count-3):periodend,((1:length(header))-1)*3+2);
%                 frame_horizontal = data(startarray(count-3):periodend,((1:length(header))-1)*3+3);
%                 frame_tangent = data(startarray(count-3):periodend,((1:length(header))-1)*3+4);
% 
%                 %Frame is declared as being active. Make the 4 second window
%                 %of data, then determine the classification by considering
%                 %frequency, peak to peak magnitude, and axial correlation
%                 %between the horizontal and vertical axes
%                 [fixed_vertical,fixed_horizontal,fixed_tangent,fixedtime] = ...
%                     fixdatanew( frame_vertical,frame_horizontal,frame_tangent,...
%                                 time,startarray(count-3),count,idealdelta);  
% 
%                  % Measure the features to be used.
%                  processed_data.vertical    = fixed_vertical;
%                  processed_data.horizontal  = fixed_horizontal;
%                  processed_data.tangent     = fixed_tangent;
%                  
%                  processed_data.periodstart = periodstart;
%                  processed_data.periodend   = periodend;
% 
% 
%                  
%                  %create feature vector
%                  [val_vec, val_struct,features] = eval(feature_extractor_function);
% 
%                  %find most likely class
% 				 maxclass = 0;
%                  maxlikelihood = -inf;
%                  for currClass = 1:TotalClasses
%                      like = -1/2*(val_vec-training_struct{currClass}.mu(chosenFeatures))*(training_struct{currClass}.invSigma*((val_vec-training_struct{currClass}.mu(chosenFeatures))'))-log(sqrt(det(training_struct{currClass}.sigma(chosenFeatures,chosenFeatures))));
%                      if(like > maxlikelihood)
%                          maxlikelihood = like;
%                          maxclass = currClass;
%                      end
%                  end
%                  %log the greatest likelihoods
%                  likelihoods(count) = maxlikelihood;
%                  
%                  %if the maximum likelihood ratio was too low (probably an
%                  %unknown class)
%                  if(maxlikelihood < unknownThreshold)
%                      maxclass = 0;
%                  end
%                  
%                  timedelta = time(periodend) - time(periodstart);
%                  classification(count) = maxclass(1);
% 
%             else
%                     classification(count) = classification(count-1);
% %                     trueClassification(count) = trueClassification(count-1);
%                     likelihoods(count) = likelihoods(count-1);
%             end
%         end
%     end
    

    
