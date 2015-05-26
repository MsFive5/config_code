%% time interpret

function [currenttimevec currenttimestr] = TimeInterpret(starttime, startoffset, currentoffset,samplerate);

currentoffsettime = currentoffset/samplerate;
realtime = startoffset + currentoffsettime; 
% realtime = currentoffsettime;
year = starttime(1);
month = starttime(2);
day = starttime(3);
hour = starttime(4);
min = starttime(5);
sec = starttime(6);

currenttimenum = datenum(year,month,day,hour,min,sec+realtime);
currenttimevec = datevec(currenttimenum);
currenttimestr = datestr(currenttimevec);