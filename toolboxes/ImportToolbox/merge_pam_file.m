%Assume:
% filename is a cell
%  Each row represents a class and
%  Each col in the row represents different files in the same class.
% filenane{class_i, file_j} = '...
% filename{1,1} = 'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\leftankle\DATA-001.CSV';
% filename{1,2} = 'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\leftankle\DATA-002.CSV';
% filename{2,1} = 'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\rightankle\DATA-001.CSV';
% filename{2,2} =
% 'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\rightankle\DATA-002.CSV';
function [outputheader,outputdata,DIFF_SAMPLING_RATE,DIFF_PAM_SERIAL] ...
    = merge_pam_file(filename)
 
outputheader=[];
outputdata = [];


data=cell(size(filename));
for k=1:size(filename,1)
    for p=1:size(filename,2)
        [mdata,header]=read_pam_csv_data_v3(filename{k,p});
        data{k,p}.mdata = mdata;
        data{k,p}.header = header;
    end 
end

% Some error checking and preprocessing
% 1. Determine if the sample rate for all files are the same.
% 2. Round off the sampling points to the nearest sampling grid.
% 3. Fix the deadband for each file.
max_sample_rate = 0;
DIFF_SAMPLING_RATE = 0;
for k=1:size(filename,1)
    for p=1:size(filename,2)
        header = data{k,p}.header;
        mdata = data{k,p}.mdata;
        %Time
        start_date  = header.start_date;
        start_time  = header.start_time;
        actual_time = datenum(start_date(1),start_date(2),start_date(3),...
                              start_time(1),start_time(2),start_time(3));

        % Find the max sampling rate
        % Detect if the sample rate is different across files.
        sample_rate = header.sample_rate;
        if(k==1 && p==1)
            max_sample_rate = sample_rate;
            ref_time        = actual_time;
            ref_time_vec    = [start_date(:); start_time(:)]';
        else
            if(max_sample_rate<sample_rate)
                max_sample_rate = sample_rate;
                DIFF_SAMPLING_RATE = 1;
                return;
            end
            if(ref_time<actual_time)
                ref_time    = actual_time;
                ref_time_vec= [start_date(:); start_time(:)]';
            end
        end
                
        if(1)
            %%%%%%%%%%%%%%%%%%
            % This is to check if there are any points that somehow
            % is set to the previous seconds:
            % eg: 1.1 1.2 1.3 .... 1.8 0.9 2.0 ...
            %                          ^ 
            %                          This should be 1.9
            % We will assume that the rows are already sorted in ascending
            % order and the problem is due to some error in the time
            % output.
            %
            %%%%%%%%%%%%%%%%%
            tmp = diff(mdata(:,1));
            idx = find(tmp<0);
            for r=1:length(idx)
                mdata(idx(r)+1,1)=mdata(idx(r),1)+1/sample_rate;
            end
%             figure(101); 
%             plot(tmp*sample_rate,'b.'); hold on;
%             plot(diff(mdata(:,1))*sample_rate,'ro');
%             hold off;
%             pause;
        end
        
        if(1)
            %%%%%%%%%%%%%%%%%%
            % This is a hack to solve the problem where the decimals 
            % in the seconds are truncated. Therefore, we assume that
            % the sample rate is right and simply set the points in 
            % each seconds from the 0:1/sample_rate:1.
            % 1. Floor of the time to find all points within a second.
            % 2. Use diff to find the transition from one second to next.
            % 3. Assume the points within a second is spaced 1/sample_rate
            %%%%%%%%%%%%%%%%%%
            tsk1 = floor(mdata(:,1));
            tsk2 = diff(tsk1);
            tsk3 = find(tsk2>=1);
            tsk4 = zeros(size(tsk1));
            tsk5 = [0;tsk3;length(tsk1)];
            for r=1:length(tsk5)-1
               tmp = tsk5(r+1)-tsk5(r);
               tmp = [0:tmp-1].'/sample_rate;
               tsk1( (tsk5(r)+1):tsk5(r+1) ) = tsk1( (tsk5(r)+1):tsk5(r+1) ) + tmp;
            end
            mdata(:,1) = tsk1;
            
%             pause; 
        end
        

        %%%%%%%%%%%%%%%%%%
        % This map to the nearest sampling point based on the sample
        % rate. If there are duplicates, it will choose the last row.
        %%%%%%%%%%%%%%%%%%
        %round off the interval of the rows to the nearest sample_interval.
        step_time= round(diff(mdata(:,1))*sample_rate);
        %cumsum to get the 'new' time of the data.
        step_time= cumsum([0;step_time])/sample_rate;
        %round off the start time to the nearest sample.
        start_new_time = round(mdata(1,1)*sample_rate)/sample_rate;
        new_time = start_new_time + step_time;

        %create a full matrix for the samples in the data.
        row = max(step_time)*sample_rate;
        new_data = zeros(row+1, 4);
        new_data(:,1) =  start_new_time + [0:row]'/sample_rate;

        % Fill up the rows with the matched entries.
        [C,IA,IB] = intersect(new_data(:,1),new_time);
        new_data(IA,[2:4]) = mdata(IB,2:4);

        %%%%%%%%%%%%%%%%%%
        % This will set the deadbands to be the previous value of the data
        % set.
        % Current method is to pad them with the previous values.
        %%%%%%%%%%%%%%%%%%
        % Find all the empty entries and pad them with the previous
        % row's data.
        idx = find(diff(IA)>1);
        for r=1:length(idx)
            new_data(idx(r)+1,2:4) = new_data(idx(r),2:4);
        end
        % save new data
        data{k,p}.mdata = new_data;
        
%         figure(1);
%         subplot(211);
%         plot(diff(new_data(:,1))*sample_rate,'.');
%         subplot(212);
%         plot(new_data(:,2:4));
%         pause(1);
    end 
end

%%%%%%%%%%%%%%%%%%%%%
% To merge files within each sensor
%%%%%%%%%%%%%%%%%%%%%
DIFF_PAM_SERIAL = 0;
for k=1:size(filename,2)
    
    % Find the start and end time of the samples in each file.
    start_time_list = zeros(size(filename,1),1);
    end_time_list   = zeros(size(filename,1),1);
    %new_start_time  = zeros(size(filename,1),1);
    new_acutal_time = zeros(size(filename,1),1);
    pam_serial = [];
    for p=1:size(filename,1)
        header = data{k,p}.header;
        if(p==1) 
            pam_serial = header.serial;
        else
            if(strcmp(pam_serial,header.serial)==0)
                DIFF_PAM_SERIAL = 1;
                return;
            end
        end
        %Time
        start_date  = header.start_date;
        start_time  = header.start_time;
        round_off_time = round(start_time(3)*sample_rate)/sample_rate;
        actual_time = datenum(start_date(1),start_date(2),start_date(3),...
                              start_time(1),start_time(2),round_off_time);
        new_acutal_time(p) = actual_time;                  
        
        start_time_list(p) = new_acutal_time(p) + data{k,p}.mdata(1,1)/(24*3600);
        end_time_list(p)   = new_acutal_time(p) + data{k,p}.mdata(end,1)/(24*3600);        
    end
    
    total_time_duration =  end_time_list(end)-start_time_list(1);
    total_time_duration = total_time_duration*24*60*60;
    total_num = round(total_time_duration*sample_rate);
    new_data = ones(total_num,4)*nan;
    new_data(:,1) = [0:total_num-1]'+ round(data{k,1}.mdata(1,1)*sample_rate);
    
    % Using intersect so that if there are duplicates, it will overwrite the
    % the existing data.
    for p=1:size(filename,1)
        tmp_time = new_acutal_time(p)-new_acutal_time(1);
        tmp_time = round(tmp_time*24*3600*sample_rate)...
                   + round(data{k,p}.mdata(:,1)*sample_rate);
        % Fill up the rows with the matched entries.
        [C,IA,IB] = intersect(new_data(:,1),tmp_time);
        new_data(IA,2:4) = data{k,p}.mdata(IB,2:4);
    end
    
    % If there are data there those not exist, pad them with the previous 
    % values.
    idx = find(isnan(new_data(:,2)));
    for r=1:length(idx)
        new_data(idx(r)+1,2:4) = new_data(idx(r),2:4);
    end
    
    new_data(:,1) = new_data(:,1)/sample_rate;
    data{k,1}.mdata = new_data;
end


%%%%%%%%%%%%%%%%%%%%%
% To merge across sensors.
%%%%%%%%%%%%%%%%%%%%%
% This uses the first set of data from sensor 1 as a reference.
% It will simply intersect with the rest of the sensor data to obtain
% the set that contains data from all the sensors.
%

% Find the start and end time of the samples in each sensor.
start_time_list = zeros(size(filename,1),1);
new_acutal_time = zeros(size(filename,1),1);
for k=1:size(filename,1)
    header = data{k,1}.header;
    %Time
    start_date  = header.start_date;
    start_time  = header.start_time;
    round_off_time = round(start_time(3)*sample_rate)/sample_rate;
    actual_time = datenum(start_date(1),start_date(2),start_date(3),...
                          start_time(1),start_time(2),round_off_time);
    new_acutal_time(k) = actual_time;                  
    start_time_list(k) = new_acutal_time(k) + data{k,1}.mdata(1,1)/(24*3600);      
end
% Calculate the offset for each sensor.
offset_time = new_acutal_time-new_acutal_time(1);
offset_time = round(offset_time*24*3600*sample_rate)/sample_rate;
% Perform intersection
for k=1:size(filename,1)
    if(k==1)
        new_data = zeros(size(data{k,1}.mdata,1),1+3*size(filename,1));
        new_data(:,1:4) = data{k,1}.mdata;
        new_data(:,1) = new_data(:,1)+offset_time(k);
        new_data(:,1) = round(new_data(:,1)*sample_rate);
    else        
        tmp_data = data{k,1}.mdata(:,1);
        tmp_data = tmp_data+offset_time(k);
        tmp_data = round(tmp_data*sample_rate);
        
        [C,IA,IB] = intersect(new_data(:,1),tmp_data);
        new_data = new_data(IA,:);
        new_data(:,[2:4]+(k-1)*3) = data{k,1}.mdata(IB,2:4);
    end
end

outputdata   = new_data;
outputheader = data{1,1}.header;
