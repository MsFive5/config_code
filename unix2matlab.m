function tm = unix2matlab(tu)
    %datestr(datenum([1970 1 1 0 0 tu/1000-7*3600]),'mmmm dd, yyyy
    %HH:MM:SS.FFF AM')
    tm = [];
%     for n = 1:length(tu)
%         tm(n) =  datenum([1970 1 1 0 0 tu(n)/1000-7*3600]);  
%     end
    temp = repmat([1970 1 1 0 0 0], length(tu), 1);
    temp(:,end) = tu/1000;
    tm = datenum(temp);
end
