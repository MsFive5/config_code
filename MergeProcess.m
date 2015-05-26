% merge files
function sensor_info = MergeProcess(inputstring,datapath)
addpath(genpath('toolboxes'));
if strcmp(inputstring,'training') == 1
    sensor_info = TrainingInfoInterpret(datapath);
    [header,data,err_msg]= merge_pam_file_v7(sensor_info);
    save([datapath '/' inputstring 'Merge.mat'],'header','data');  
    save([datapath '/' inputstring 'sensor_info.mat'],'sensor_info');
elseif strcmp(inputstring,'dailyprocess') == 1
    sensor_info = DailyInfoInterpret(datapath);
    % to remove empty cells
    emptyCells = cellfun(@isempty,sensor_info);
    sensor_info(emptyCells) = []
    [header,data,err_msg]= merge_pam_file_v7(sensor_info);
    save([datapath '/' inputstring 'Merge.mat'],'header','data');
    save([datapath '/' inputstring 'sensor_info.mat'],'sensor_info');    
end

