%Assume:
% sensor_info{1}.sensorName   = 'leftankle';
% sensor_info{1}.sensorSerial = 'CCDC220090387';
% sensor_info{1}.files{1} = ...
%     'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\leftankle\DATA-001.CSV';
% sensor_info{1}.files{2} = ...
%     'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\leftankle\DATA-002.CSV';
% 
% sensor_info{2}.sensorName   = 'rightankle';
% sensor_info{2}.sensorSerial = 'CCDC220090378';
% sensor_info{2}.files{1} = ...
%     'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\rightankle\DATA-001.CSV';
% sensor_info{2}.files{2} = ...
%     'D:\tsk\UCLA\2009\Kaiser\GUI_09_26_09\testcode\rightankle\DATA-002.CSV';
%
function [outputheader,outputdata,err_msg]= merge_pam_file_v5(sensor_info)
 
err_msg = [];
outputheader=[];
outputdata = [];
num_sensors = length(sensor_info);

FLAG_REPORT_INCONSISTENCY = 1;

data=cell(1,num_sensors);
for k=1:num_sensors
    num_of_files = length(sensor_info{k}.files);
    data{k} = cell(1,num_of_files);
    for p=1:num_of_files
        file_name = sensor_info{k}.files{p};
        [mdata,header]=read_pam_csv_data_v4(file_name,0);
        data{k}{p}.mdata = mdata;
        data{k}{p}.header = header;
        if(strcmp(sensor_info{k}.sensorSerial,header.serial)==0)
            err_msg = 'ERROR: The serial number in a sensor list is not consisitent.';
            return;
        end
    end 
end

% Some error checking and preprocessing
% 1. Determine if the sample rate for all files are the same.
% 2. Round off the sampling points to the nearest sampling grid.
% 3. Fix the deadband for each file.
max_sample_rate = 0;
DIFF_SAMPLING_RATE = 0;
for k=1:num_sensors
    num_of_files = length(sensor_info{k}.files);
    for p=1:num_of_files
        header = data{k}{p}.header;
        mdata = data{k}{p}.mdata;
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
                err_msg = 'ERROR: Sample rate in the csv files are not consistent.';
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
            if(~isempty(idx) && FLAG_REPORT_INCONSISTENCY)
                fprintf('File: %s.\n',sensor_info{k}.files{p});
                fprintf('The time in the file is not in ascending order at approximately time:\n');                    
                fprintf('%.3f -> %.3f, ', [mdata(idx,1)'; mdata(idx+1,1)']);
                fprintf('\n\n');
            end
            
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
            tmp = round(diff((mdata(:,1)*sample_rate)));
            idx = find(tmp<1);
            if(~isempty(idx)&& FLAG_REPORT_INCONSISTENCY)
                fprintf('File: %s.\n',sensor_info{k}.files{p});
                fprintf('Some of the time intervals are less than the sampling interval:\n');
                fprintf('%.3f -> %.3f, ', [mdata(idx,1)'; mdata(idx+1,1)']);
                fprintf('\n\n'); 
            end
            
%             if(0)
%                 %%%%%%%%%%%%%%%%%%
%                 % This is a hack to solve the problem where the decimals 
%                 % in the seconds are truncated. Therefore, we assume that
%                 % the sample rate is right and simply set the points in 
%                 % each seconds from the 0:1/sample_rate:1.
%                 % 1. Floor of the time to find all points within a second.
%                 % 2. Use diff to find the transition from one second to next.
%                 % 3. Assume the points within a second is spaced 1/sample_rate
%                 %%%%%%%%%%%%%%%%%%
%                 tsk1 = floor(mdata(:,1));
%                 tsk2 = diff(tsk1);
%                 tsk3 = find(tsk2>=1);
%                 tsk4 = zeros(size(tsk1));
%                 tsk5 = [0;tsk3;length(tsk1)];
%                 for r=1:length(tsk5)-1
%                    tmp = tsk5(r+1)-tsk5(r);
%                    tmp = [0:tmp-1].'/sample_rate;
%                    tsk1( (tsk5(r)+1):tsk5(r+1) ) = tsk1( (tsk5(r)+1):tsk5(r+1) ) + tmp;
%                 end
%                 mdata(:,1) = tsk1;
%             end
        end
        

        %%%%%%%%%%%%%%%%%%
        % This map to the nearest sampling point based on the sample
        % rate. If there are duplicates, it will choose the last row.
        %%%%%%%%%%%%%%%%%%
if(0)        
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
else
        %round off the interval of the rows to the nearest sample_interval.
        new_time = round(mdata(:,1)*sample_rate)/sample_rate;
        max_step = round((max(new_time)-min(new_time))*sample_rate)+1;
        
        %create a full matrix for the samples in the data.
        row = max_step;
        new_data = zeros(row+1, 4);
        new_data(:,1) =  new_time(1,1) + [0:row]'/sample_rate;
        
end
        

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
        len = diff(IA); 
        idx = find(len>1);
        for r=1:length(idx)
            new_data(IA(idx(r))+(1:len(idx(r))-1),2:4) = ...
                repmat(new_data(IA(idx(r)),2:4),len(idx(r))-1,1);
        end
        if(~isempty(idx)&& FLAG_REPORT_INCONSISTENCY)
            fprintf('File: %s.\n',sensor_info{k}.files{p});
            fprintf('There are deadbands\n');
            fprintf('%.3f -> %.3f, ', [mdata(IB(idx),1)'; mdata(IB(idx)+1,1)']);
            fprintf('\n\n'); 
        end
        
        % save new data
        data{k}{p}.mdata = new_data;
        

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
sdata = cell(1,num_sensors);
for k=1:num_sensors
    num_of_files = length(sensor_info{k}.files); 
    % Find the start and end time of the samples in each file.
    start_time_list = zeros(num_of_files,1);
    end_time_list   = zeros(num_of_files,1);
    new_acutal_time = zeros(num_of_files,1);
    pam_serial = [];
    for p=1:num_of_files
        header = data{k}{p}.header;
        if(p==1) 
            pam_serial = header.serial;
        else
            if(strcmp(pam_serial,header.serial)==0)
                DIFF_PAM_SERIAL = 1;
                err_msg = 'ERROR: Serial numbers are not consistent';
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
        
        start_time_list(p) = new_acutal_time(p) + data{k}{p}.mdata(1,1)/(24*3600);
        end_time_list(p)   = new_acutal_time(p) + data{k}{p}.mdata(end,1)/(24*3600);        
    end
    
    %Find the earliest start time
    [first_start_time, first_start_time_idx] = min(start_time_list);
    %Find the last end time.
    [last_end_time, last_end_time_idx] = max(end_time_list);
    
    total_time_duration =  last_end_time-first_start_time;
    total_time_duration = total_time_duration*24*60*60;
    total_num = round(total_time_duration*sample_rate);
    new_data = ones(total_num,4)*nan;
    new_data(:,1) = [0:total_num-1]'+ ...
        round(data{k}{first_start_time_idx}.mdata(1,1)*sample_rate);
    
    % Using intersect so that if there are duplicates, it will overwrite the
    % the existing data.
    for p=1:num_of_files
        tmp_time = new_acutal_time(p)-new_acutal_time(first_start_time_idx);
        tmp_time = round(tmp_time*24*3600*sample_rate)...
                   + round(data{k}{p}.mdata(:,1)*sample_rate);
        % Fill up the rows with the matched entries.
        [C,IA,IB] = intersect(new_data(:,1),tmp_time);
        new_data(IA,2:4) = data{k}{p}.mdata(IB,2:4);
    end
    
    if(0)
        % If there are data there those not exist, pad them with the previous 
        % values.
        idx = find(isnan(new_data(:,2)));
        for r=1:length(idx)
            new_data(idx(r)+1,2:4) = new_data(idx(r),2:4);
        end
    else
        % If there are data there those not exist, remove them
        idx = find(isnan(new_data(:,2)));
        new_data(idx,:) = [];
    end
    
    new_data(:,1) = new_data(:,1)/sample_rate;
    sdata{k}.header = data{k}{first_start_time_idx}.header;
    sdata{k}.header.sensorName = sensor_info{k}.sensorName;
    sdata{k}.mdata = new_data;
end


%%%%%%%%%%%%%%%%%%%%%
% To merge across sensors.
%%%%%%%%%%%%%%%%%%%%%
% This uses the first set of data from sensor 1 as a reference.
% It will simply intersect with the rest of the sensor data to obtain
% the set that contains data from all the sensors.
%

% Find the start and end time of the samples in each sensor.
start_time_list = zeros(num_sensors,1);
new_acutal_time = zeros(num_sensors,1);
for k=1:num_sensors
    header = sdata{k}.header;
    %Time
    start_date  = header.start_date;
    start_time  = header.start_time;
    round_off_time = round(start_time(3)*sample_rate)/sample_rate;
    actual_time = datenum(start_date(1),start_date(2),start_date(3),...
                          start_time(1),start_time(2),round_off_time);
    new_acutal_time(k) = actual_time;                  
    start_time_list(k) = new_acutal_time(k) + sdata{k}.mdata(1,1)/(24*3600);      
end
% Calculate the offset for each sensor.
offset_time = new_acutal_time-new_acutal_time(1);
offset_time = round(offset_time*24*3600*sample_rate)/sample_rate;
% Perform intersection
for k=1:num_sensors
    if(k==1)
        new_data = zeros(size(sdata{k}.mdata,1),1+3*num_sensors);
        new_data(:,1:4) = sdata{k}.mdata;
        new_data(:,1) = new_data(:,1)+offset_time(k);
        new_data(:,1) = round(new_data(:,1)*sample_rate);
    else        
        tmp_data = sdata{k}.mdata(:,1);
        tmp_data = tmp_data+offset_time(k);
        tmp_data = round(tmp_data*sample_rate);
        
        [C,IA,IB] = intersect(new_data(:,1),tmp_data);
        new_data = new_data(IA,:);
        new_data(:,[2:4]+(k-1)*3) = sdata{k}.mdata(IB,2:4);
    end
end
new_data(:,1) = new_data(:,1)/sample_rate;
outputdata   = new_data;
outputheader = cell(size(sdata));
for l=1:length(sdata)
    outputheader{l} = sdata{l}.header;
end
