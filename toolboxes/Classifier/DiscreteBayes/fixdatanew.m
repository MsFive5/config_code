function [fixeddataV,fixeddataH,fixeddataT,fixedtime] = fixdatanew(datainV,datainH,datainT,time,startindex,count,idealdelta)
fixeddataV = zeros(1,size(datainV,2));
fixeddataH = zeros(1,size(datainH,2));
fixeddataT = zeros(1,size(datainT,2));
for l= 1:size(datainV,2)
    fixedtime(1) = time(startindex);
    fixeddataV(1,l) = datainV(1,l);
    fixeddataH(1,l) = datainH(1,l);
    fixeddataT(1,l) = datainT(1,l);
    fixedtimecount = 2;
    for x_count = 1:length(datainV)-1
        delta = time(startindex+x_count) - time(startindex+x_count-1);
        if(abs(delta) - abs(idealdelta) > abs(0.5*idealdelta))
            fillerpoints = round(abs(delta)/abs(idealdelta));
            for y = 1:fillerpoints
                fixedtime(fixedtimecount) = time(startindex+x_count-1) + y*idealdelta;
                fixeddataV(fixedtimecount,l) = fixeddataV(fixedtimecount-1,l);
                fixeddataH(fixedtimecount,l) = fixeddataH(fixedtimecount-1,l);
                fixeddataT(fixedtimecount,l) = fixeddataT(fixedtimecount-1,l);
                fixedtimecount = fixedtimecount + 1;
            end
        else
            fixedtime(fixedtimecount) = time(startindex+x_count-1);
            fixeddataV(fixedtimecount,l) = datainV(x_count,l);
            fixeddataH(fixedtimecount,l) = datainH(x_count,l);
            fixeddataT(fixedtimecount,l) = datainT(x_count,l);
            fixedtimecount = fixedtimecount + 1;
        end
    end
end