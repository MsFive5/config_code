% do detailed parameter analysis
function [peakoutput,indexoutput,cadoutput,speedoutput,stridelenoutput,numofsteps,flag] = walkingparameteranalysis(input,para,walksection,samplerate,path)
paravector = para.vector2;
para = para.para;
peakoutput = [];
indexoutput = [];
cadoutput = [];
speedoutput = [];
stridelenoutput = [];

numofsteps = 0;
data = input.data;
startoffset = data(1,1);
time = input.data(:,1)-startoffset;
flag = 0;
for walksectioncount = 1:length(walksection)
    startindex = max(find(time<=(walksection(walksectioncount).starttime)));
    endindex = min(find(time>= (walksection(walksectioncount).endtime)));
    stridesectionleft = groupstrides(data,startindex,endindex,'left',40);
    stridesectionright = groupstrides(data,startindex,endindex,'right',40);
    leftsteps = 0; rightsteps = 0 ; 

    if length(stridesectionleft) == 0 ||length(stridesectionright) == 0
        continue;
    else
        peakoutput = [peakoutput;stridesectionright.index'];
        peakoutput = sort(peakoutput);
        for n = 1:length(stridesectionleft)
            leftsteps = leftsteps+ length(stridesectionleft(n).index);
        end
        for n = 1:length(stridesectionright)
            rightsteps = rightsteps + length(stridesectionright(n).index);
        end
        numofsteps = numofsteps + leftsteps + rightsteps;  
    end

    
    allsection = matchsection(stridesectionleft,stridesectionright);
     if length(allsection) == 0 || length(allsection.leftankleindex)<2
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
         if length(allsection.leftankleindex)>length(allsection.rightankleindex)
             ankleindex = allsection.leftankleindex;
         else
             ankleindex = allsection.rightankleindex;
         end
         for j = 1: length(ankleindex)-1
                    % calculate symmetry
                    anklestart  = ankleindex(j);
                    ankleend = ankleindex(j+1);
%                     rightswinglen = similarityscore(symrighttemplate.data(:,5:7),rawdata.data(rightindexstart:rightindexend,5:7));
% 
%                     leftindexstart = allsection.leftankleindex(j)+startindex;
%                     leftindexend = allsection.leftankleindex(j+1)+startindex;
%                     leftswinglen = similarityscore(symlefttemplate.data(:,2:4),rawdata.data(leftindexstart:leftindexend,2:4));
% 
%                     symmetry(j) = rightswinglen/leftswinglen;
                    time(j) = (ankleindex(j+1) - ankleindex(j))/40;
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
[indexvec indexstr] = TimeInterpret(starttime, startoffset, indexoutput,samplerate);

%% generate txt files
savefilename = [path '/dailyprocess_','realtimeresultwithoutratio'];
fid = fopen(savefilename,'w');
validind = find(speedoutput>0.1);
ind = find(cadoutput>0);
fprintf(fid,'number of steps is %d, total distance is %f\n',numofsteps,sum(stridelenoutput(ind)));

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

fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',maxvalue,mean(speedoutput(validind)),min(speedoutput(validind)));
for jj = 1:length(cadoutput)
    if cadoutput(jj)<0 && speedoutput(jj)<0.1
    else
        
        fprintf(fid,'%s\t%f %f %f\n',indexstr(jj,:),cadoutput(jj),speedoutput(jj),stridelenoutput(jj));
    end
end
if fid>0
    flag = 1; 
end
fclose(fid);