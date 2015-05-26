function filename_list = create_pam_data(pam_settings)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process each single data on its own.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% There may be multiple csv files in each day.
% Each element in the vector represents some information relate to each
% csv file.
%
% data_mat  : contains the Time, X, Y, Z data of the entire day's
%             csv collection. 
%             The Time column has been set such that it starts with respect
%             to the first data row of data_mat.
% date_vec  : [YYYY MM DD]
% start_vec : time of day in second
%             indicate the start time of the segment
% index_vec : start index of the current segment.
% num_vec   : size of data from start_index.
% gain_vec  : gain of data in the segment.
% sample_rate_vec : sample rate of data in the segment
% deadband_vec : deadband used in the segment
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_n             = pam_settings.start_n;
root_data_dir       = pam_settings.root_data_dir;
pam_device          = pam_settings.pam_device;
number_of_days      = pam_settings.number_of_days;
filename_list       = cell(number_of_days,1);

for k=1:number_of_days
    cur_date = datestr(start_n+k-1, 'yyyymmdd');
	cur_dir  = sprintf('%s\\%s',root_data_dir,pam_device);        
	filename = sprintf('%s\\pam_raw_%s_%s.mat', ...
                        cur_dir, ...
                        pam_device, cur_date);
    if(exist(filename,'file'))
       % load raw pam data and calculate the size.
       pam = load(filename,'data','header');     
       totnum = 0;
       num_data = length(pam.data);
       for p=1:num_data
           totnum = totnum + size(pam.data{p},1);
       end
       
       % Init the data size
       date_vec         = zeros(1,3);
       start_vec        = zeros(num_data,1);
       index_vec        = zeros(num_data,1);
       num_vec          = zeros(num_data,1);
       gain_vec         = zeros(num_data,1);
       sample_rate_vec  = zeros(num_data,1);
       deadband_vec     = zeros(num_data,1);
       data_mat         = zeros(totnum,4);
       
       date_vec = datevec(start_n+k-1);
       curCnt = 1;
       for p=1:length(pam.data)
           tmp1 = pam.header{p}.start_date;
           tmp2 = pam.header{p}.start_time;
           tmp3 = [tmp2(1) tmp2(2) tmp2(3)]*[3600 60 1]';
           start_vec(p)        = tmp3;
           index_vec(p)        = curCnt+1;
           num_vec(p)          = size(pam.data{p},1);
           if( pam.header{p}.gain == 'low')
                gain_vec(p)	= 0;
           elseif( pam.header{p}.gain == 'high')
                gain_vec(p)	= 1;
           else
               fprintf('gain of pam is %s\n',pam.header{p}.gain);
               fprintf('Please update the code in create_pam_data.m to assign the gain vector correctly\n',...
                       pam.header{p}.gain);
               keyboard;
           end
           sample_rate_vec(p)  = pam.header{p}.sample_rate;
           deadband_vec(p)     = pam.header{p}.deadband;
           
           tmp2 = curCnt+(1:size(pam.data{p},1));
           tmp3 = pam.data{p};
           tmp3(:,1) = tmp3(:,1)+ start_vec(p) - start_vec(1); 
           data_mat(tmp2,:)    = tmp3;
           
           curCnt = curCnt + size(pam.data{p},1);
       end
       
        cur_date = datestr(start_n+k-1, 'yyyymmdd');
        cur_dir  = sprintf('%s\\%s',root_data_dir,pam_device);        
        filename = sprintf('%s\\pam_%s_%s', ...
                            cur_dir, ...
                            pam_device, cur_date);
        save(filename,'start_vec','index_vec','num_vec',...
                       'gain_vec','sample_rate_vec','deadband_vec',...
                       'data_mat','date_vec');
                   
        filename_list{k} = [filename '.mat'];
    end
end
