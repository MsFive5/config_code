function [mdata,header]=read_pam_csv_data_v2(filename)

DEBUG_FLAG = 0;

% filename = 'sample.csv';
mdata = [];
header = [];

% ASSUME the last field name must be last_fieldname.
last_fieldname = 'Headers';

fid=fopen(filename);

k=0;
while(1)
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    k=k+1;
    
    cur_field_cell = textscan(tline,'%s','delimiter',',');
    cur_field = cur_field_cell{1}{1}(2:end);
    if(strcmp(last_fieldname,cur_field))
        break;
    end
    switch cur_field
        case 'Title'
        case 'Version'
            %;Version, 465, Build num, 0x11E, Build date, 20090218 14:11:20,  SN:CCDC020090138  
            [A, count, errmsg, nextindex] = ...
            sscanf(tline,';%*s%*c %d%*c %*s %*s%*c %x%*c %*s %*s%*c %d %d:%d:%d%*c  SN:%s' );
            data.version = A(1);
            data.build_num = dec2hex(A(2));
            data.build_date = A(3);
            data.build_time = [A(4) A(5) A(6)];
            data.serial = char(A(7:end))';
        case 'Start_time'
            %;Start_time, 2009-05-03, 12:14:30.000
            format_str = ';%*s%*c %d-%d-%d %*c %d:%d:%f';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.start_date = [A(1) A(2) A(3)];
            data.start_time = [A(4) A(5) A(6)];            
        case 'Temperature'
            %;Temperature, 31.50, deg C
            format_str = ';%*s%*c %f %*c %*s %*s';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.temp = A(1);
        case 'BatteryVoltage'
            %;BatteryVoltage, 1028,mV
            format_str = ';%*s%*c %d %*c %*s';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.mV = A(1);
        case 'Gain'
            %;Gain, low
            format_str = ';%*s%*c %s';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.gain = char(A);
        case 'SampleRate'
            %;SampleRate, 16,Hz
            format_str = ';%*s%*c %d%*c%*s';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.sample_rate = A;
        case 'Deadband'
            %;Deadband, 20
            format_str = ';%*s%*c %d%';
            [A, count, errmsg, nextindex] = sscanf(tline, format_str);
            data.deadband = A;
        case 'Headers'
        otherwise
            disp(cur_field);
    end
end
fclose(fid);

% if(0)
% for k=1:9
%     tline = fgetl(fid);
%     if ~ischar(tline), break, end
%     %disp(tline)
%     
%     switch k
%         case 1
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%         case 2
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%      %;Version, 465, Build num, 0x11E, Build date, 20090218 14:11:20,  SN:CCDC020090138  
%             [A, count, errmsg, nextindex] = ...
%             sscanf(tline,';%*s%*c %d%*c %*s %*s%*c %x%*c %*s %*s%*c %d %d:%d:%d%*c  SN:%s' );
%             data.version = A(1);
%             data.build_num = dec2hex(A(2));
%             data.build_date = A(3);
%             data.build_time = [A(4) A(5) A(6)];
%             data.serial = char(A(7:end))';
%         case 3
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%             %;Start_time, 2009-05-03, 12:14:30.000
%             format_str = ';%*s%*c %d-%d-%d %*c %d:%d:%f';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.start_date = [A(1) A(2) A(3)];
%             data.start_time = [A(4) A(5) A(6)];
%         case 4
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%             %;Temperature, 31.50, deg C
%             format_str = ';%*s%*c %f %*c %*s %*s';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.temp = A(1);
%         case 5
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%             %;BatteryVoltage, 1028,mV
%             format_str = ';%*s%*c %d %*c %*s';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.mV = A(1);
%         case 6
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%             %;Gain, low
%             format_str = ';%*s%*c %s';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.gain = char(A);
%         case 7
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%             %;SampleRate, 16,Hz
%             format_str = ';%*s%*c %d%*c%*s';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.sample_rate = A;
%         case 8
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end    
%             %;Deadband, 20
%             format_str = ';%*s%*c %d%';
%             [A, count, errmsg, nextindex] = sscanf(tline, format_str);
%             data.deadband = A;
%         case 9
%             if(DEBUG_FLAG)
%                 disp(tline);
%             end
%     end
% end
% fclose(fid);
% end

mdata = csvread(filename,k,0);
header = data;
