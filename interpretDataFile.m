% file interpret
function [time, data] = interpretDataFile(fileName)

% edit by eyuen 2014-09-24

data = csvread(fileName);
% udata = [];
% for n = 2 : size(data, 1)
%     udata(n,:) = (sscanf(data{n}, '%ld,[%d, %d, %d],[%d, %d, %d],[%ld, %ld, %ld, %ld]'))';
% end

% timeArray = [];
% dataArray = [];
% for n = 2 : length(data)
%    cData = data(n);
%    cArray = sscanf(cData{1}, '%ld,[%d, %d, %d],[%d, %d, %d],[%d, %d, %d, %d]');
%    timeArray = [timeArray ; cArray(1)];
%    dataArray = [dataArray; cArray(2 : end)'];
% end

% data = csvread(fileName, 1);
% time = data(:,1);
% data = data(:,2:end);

% time = timeArray;
% data = dataArray;

% time = udata(:,1);
% data = udata(:,2:end);
time = data(:,1);
data = data(:,2:end);
