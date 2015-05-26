function [trainingsection] = delimitTraining2(inputDatastructure,templatestructure,threshold,numofbouts,datapath)
trainingsection = [];
input = inputDatastructure.data;
inputheader = inputDatastructure.header;
templatestructureright = templatestructure; 
    currenttime = clock;    
    fid = fopen([datapath '/' 'alertmsg'],'w');
    load([datapath '/' 'trainingsensor_info.mat']);
    fprintf(fid,'currenttime is %s %s %s %s %s %s,please delimit the training section manually for %s\n',num2str(currenttime(1)),num2str(currenttime(2)),num2str(currenttime(3)),num2str(currenttime(4)),...
        num2str(currenttime(5)),num2str(currenttime(6)),sensor_info{1}.patientID);
    fclose(fid);
% templatestructureright.data(:,2) = templatestructure.data(:,2)*(-1);
% templatestructureright.data(:,4) = templatestructure.data(:,4)*(-1);
% [leftsection,distanceleft,flagleft,signatureleft] = findmatch(input(:,2:4),templatestructure,threshold);
% [rightsection,distanceright,flagright,signatureright] = findmatch(input(:,5:7),templatestructureright,threshold);
% 
% if length(leftsection) + length(rightsection) == numofbouts
%     if length(leftsection) == 0 
%         trainingsection = rightsection;
%     elseif length(rightsection) == 0
%         trainingsection = leftsection;
%     else % some tapping happends on right while some on left
%         startarray = sort([leftsection(1:end).start rightsection(1:end).start]);
%         endarray = sort([leftsection(1:end).end rightsection(1:end).end]);
%         for n = 1:numofbouts
%             trainingsection(n).start = startarray(n);
%             trainingsection(n).end = endarray(n);
%         end
%     end
% elseif length(leftsection) + length(rightsection) > numofbouts
%     % generate alert msg
%     currenttime = clock;    
%     fid = fopen([datapath '/' 'alertmsg'],'w');
%     load([datapath '/' 'trainingsensor_info.mat']);
%     fprintf(fid,'currenttime is %s,%s,%s, %s:%s:%s,please delimit the training section manually for %s\n',num2str(currenttime(1)),num2str(currenttime(2)),num2str(currenttime(3)),num2str(currenttime(4)),...
%         num2str(currenttime(5)),num2str(currenttime(6)),sensor_info{1}.patientID);
%     fclose(fid);
% elseif length(leftsection) + length(rightsection) < numofbouts
%     % generate alert msg
%     currenttime = clock;    
%     fid = fopen([datapath '/' 'alertmsg'],'w');
%     load([datapath '/' 'trainingsensor_info.mat']);
%     fprintf(fid,'currenttime is %s %s %s %s %s %s,please delimit the training section manually for %s\n',num2str(currenttime(1)),num2str(currenttime(2)),num2str(currenttime(3)),num2str(currenttime(4)),...
%         num2str(currenttime(5)),num2str(currenttime(6)),sensor_info{1}.patientID);
%     fclose(fid);
% end