function create_raw_pam_data(file_list, pam_settings)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read each csv file iteratively.
% Simply compile each day's data in a mat file.
% Save the mat file at 'roor_dir\pam_device\'
% Each mat file is denoted as 'pam_<DEVICE_NAME>_<YYYYMMDD>.mat'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
number_of_days      = pam_settings.number_of_days;
start_n             = pam_settings.start_n;
root_data_dir       = pam_settings.root_data_dir;
pam_device          = pam_settings.pam_device;

for k=1:number_of_days
    if(~isempty(file_list{k}))
        num_file = length(file_list{k}.file_list);
        data    = cell(1,num_file);
        header  = cell(1,num_file);
        for p=1:num_file           
            filename = sprintf('%s\\%s', ...
                            file_list{k}.dirname, ...
                            file_list{k}.file_list(p).name);
        	[tmp1,tmp2]=read_pam_csv_data(filename);
            data{p}     = tmp1;
            header{p}   = tmp2;
        end
        cur_date = datestr(start_n + k-1, 'yyyymmdd');
        cur_dir  = sprintf('%s\\%s',root_data_dir,pam_device);        
        filename = sprintf('%s\\pam_raw_%s_%s', ...
                            cur_dir, ...
                            pam_device, cur_date);
        save(filename,'data','header');
    end
end