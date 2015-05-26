function [fixeddataV,fixeddataH,fixeddataT,fixedtime] = fixdatanew(datainV,datainH,datainT,time,startindex,count,idealdelta)

fixedtime(1) = time(startindex);
fixeddataV(1) = datainV(1);
fixeddataH(1) = datainH(1);
fixeddataT(1) = datainT(1);
fixedtimecount = 2;
for x_count = 1:length(datainV)-1
    delta = time(startindex+x_count) - time(startindex+x_count-1);
    if(abs(delta) - abs(idealdelta) > abs(0.5*idealdelta))
        fillerpoints = round(abs(delta)/abs(idealdelta));
        for y = 1:fillerpoints
            fixedtime(fixedtimecount) = time(startindex+x_count-1) + y*idealdelta;
            fixeddataV(fixedtimecount) = fixeddataV(fixedtimecount-1);
            fixeddataH(fixedtimecount) = fixeddataH(fixedtimecount-1);
            fixeddataT(fixedtimecount) = fixeddataT(fixedtimecount-1);
            fixedtimecount = fixedtimecount + 1;
        end
    else
        fixedtime(fixedtimecount) = time(startindex+x_count-1);
        fixeddataV(fixedtimecount) = datainV(x_count);
        fixeddataH(fixedtimecount) = datainH(x_count);
        fixeddataT(fixedtimecount) = datainT(x_count);
        fixedtimecount = fixedtimecount + 1;
    end
end