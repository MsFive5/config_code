function download_pam(url, pam_device, start_date, number_of_days, wget_settings)

wget_dir            = wget_settings.wget_dir;
wget_download_dir   = wget_settings.wget_download_dir;
wget_file_type      = wget_settings.wget_file_type;

pam_url_dir = [url '/' pam_device '/'];
start_n = datenum(start_date(1),start_date(2),start_date(3));  

for k=1:number_of_days
    cur_date = datestr(start_n+k-1, 'yyyymmdd');
    pam_date_url_dir = [pam_url_dir cur_date '/'];
    wget_cmd = sprintf('%s\\wget  -N -nv --ignore-case -A %s -np -nH --cut-dirs=1 -r -P %s %s',...
                        wget_dir, wget_file_type, wget_download_dir, pam_date_url_dir);
    system(wget_cmd);
end