% do detailed parameter analysis
function [peakoutput,indexoutput,cadoutput,speedoutput,stridelenoutput,numofsteps,flag] = walkingparameteranalysis_new2(input,para,walksection,samplerate,path,sensor_info)
paravector = para.vector2;
para = para.para;
peakoutput = [];
indexoutput = [];
cadoutput = [];
speedoutput = [];
stridelenoutput = [];

numofsteps = 0;
numofstrides = 0;
data = input.data;
initialTime = data(1,1);
timeArray = input.data(:,1)-initialTime;
flag = 0;
hemiflag = 0;
if  strcmp(sensor_info{1}.hemiside, '1 ') == 1
    %sensor_info{1}.hemiside == 1
    hemiflag = 1; % leftside hemiparetic
else
    hemiflag = 0 ;% rightside hemiparetic
end

for walksectioncount = 1:length(walksection)
    startindex = max(find(timeArray<=(walksection(walksectioncount).starttime)));
    endindex = min(find(timeArray>= (walksection(walksectioncount).endtime)));
    if  hemiflag == 1 
        [startoffset,stridesection] = groupstrides(data,startindex,endindex,'right',40);
    else
        [startoffset,stridesection] = groupstrides(data,startindex,endindex,'left',40);
    end
    strides = 0;  
    ankleindex = [];
    if length(stridesection) == 0
        continue;
    else      
        for n = 1:length(stridesection)
            ankleindex = [ankleindex;stridesection(n).index'];
            peakoutput = [peakoutput;stridesection(n).index'];
            strides = strides+ length(stridesection(n).index);
        end
        peakoutput = sort(peakoutput);
        peakoutput = peakoutput-startoffset;
%        numofsteps = numofsteps +strides*2;  
    end

    
%     allsection = matchsection(stridesectionleft,stridesectionright);
%     allsection.rightankleindex =  stridesectionright.index;

     if length(ankleindex) == 0 || length(ankleindex)<2
%             symmetry = -1;
%             cadence = -1;
%             speed = -1;
%             stridelen = -1;
%             symmetry = -1; 
%             indexoutput = [indexoutput;stridesectionleft.index(1)+startindex];
%             cadoutput = [cadoutput;cadence];
%             speedoutput = [speedoutput;speed];
%             stridelenoutput = [stridelenoutput;stridelen];
%             symmetryoutput = [symmetryoutput;symmetry];  
     else
%          if length(allsection.leftankleindex)>length(allsection.rightankleindex)
%              ankleindex = allsection.leftankleindex;
%          else
              %ankleindex = allsection.rightankleindex;
%          end
         for j = 1: length(ankleindex)-1
                    % calculate symmetry
                    anklestart  = ankleindex(j);
                    ankleend = ankleindex(j+1);
                    numofsteps = numofsteps + 1;
%                     rightswinglen = similarityscore(symrighttemplate.data(:,5:7),rawdata.data(rightindexstart:rightindexend,5:7));
% 
%                     leftindexstart = allsection.leftankleindex(j)+startindex;
%                     leftindexend = allsection.leftankleindex(j+1)+startindex;
%                     leftswinglen = similarityscore(symlefttemplate.data(:,2:4),rawdata.data(leftindexstart:leftindexend,2:4));
% 
%                     symmetry(j) = rightswinglen/leftswinglen;
                    time(j) = (ankleindex(j+1) - ankleindex(j))/40;
                    if isnan(anklestart) ==1
                        continue;
                    end
                    cadence(j) = 2*60/time(j);
                    if para(2) == 0 && length(paravector) == 1
                        speed(j) = paravector;
                    else
                        speed(j) = para(1)*time(j)+para(2);                       
                    end

                    if (speed(j)<0) 
                        cadence(j) = -1;
                    end
                
                    stridelen(j) = speed(j)*60*2/cadence(j);
                    if (stridelen(j)>2.5) ||(stridelen(j)<0.1)
                        cadence(j) = -1;
                    end
                    indexoutput = [indexoutput;anklestart];
                    cadoutput = [cadoutput;cadence(j)];
                    speedoutput = [speedoutput;speed(j)];
                    stridelenoutput = [stridelenoutput;stridelen(j)];
%                     symmetryoutput = [symmetryoutput;symmetry(j)];    
         end 
     end            
end
ymd = input.header{1}.start_date;
hms = input.header{1}.start_time;
starttime = [ymd';hms'];
[indexvec indexstr] = TimeInterpret(starttime, initialTime, indexoutput,samplerate);

%% generate txt files
savefilename = [path '/dailyprocess_','realtimeresultwithoutratio'];
fid = fopen(savefilename,'w');
validind = find(speedoutput>0.1);
ind = find(cadoutput>0);



if length(speedoutput)<1
    return;
end
value = sort(speedoutput);
if value(end) >2
    maxind = find(value<2,1,'last');
    maxvalue = value(maxind);
else
    maxvalue = value(end);
end

ind1 = find(cadoutput>0);
ind2 = find(speedoutput(ind1)>0.1);
ind3 = find(speedoutput(ind2)<2);
ind4 = find(stridelenoutput<3);
ind5 = intersect(ind2, ind3);
ind6 = intersect(ind4, ind5);
ind6 = intersect(ind1,ind6);
outputind = [];
numofsteps = length(ind6);
fprintf(fid,'number of steps is %d, total distance is %f\n',numofsteps,sum(stridelenoutput(ind6)));
fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',maxvalue,mean(speedoutput(ind6)),min(speedoutput(ind6)));
for jj = 1:length(cadoutput)
    if cadoutput(jj)<0 || speedoutput(jj)<0.1 ||speedoutput(jj)>2 ||abs(stridelenoutput(jj))>3
    else
        outputind = [outputind;jj];
        fprintf(fid,'%s\t%f %f %f %d\n',indexstr(jj,:),cadoutput(jj),speedoutput(jj),stridelenoutput(jj), indexoutput(jj));
    end
end
steps = indexoutput(outputind);
save([path '/results/' 'steplabel.mat'],'steps');
if fid>0
    flag = 1; 
end
fclose(fid);