function file_list = search_for_files(pam_settings) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% While loop to search each dir for csv files.
%

number_of_days      = pam_settings.number_of_days;
start_n             = pam_settings.start_n;
root_data_dir       = pam_settings.root_data_dir;
pam_device          = pam_settings.pam_device;
data_file_ext       = pam_settings.data_file_ext;

file_list = cell(number_of_days,1);
for k=1:number_of_days    
    cur_date = datestr(start_n+k-1, 'yyyymmdd');
    search_dir = sprintf('%s\\%s\\%s',root_data_dir,pam_device,cur_date);
    search_key =  [search_dir '\*.' data_file_ext];                                
    csv_filename = dir(search_key);
    if(~isempty(csv_filename))
        file_list{k}.file_list = csv_filename;
        file_list{k}.dirname = [search_dir];
    end
end 