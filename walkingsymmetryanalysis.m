% do detailed parameter analysis
function [indexoutput,cadoutput,speedoutput,stridelenoutput,symmetryoutput,numofsteps,flag] = walkingsymmetryanalysis(input,para,walksection,samplerate,datapath,lefttemplate,righttemplate)
indexoutput = [];
cadoutput = [];
speedoutput = [];
stridelenoutput = [];
symmetryoutput = [];
numofsteps = 0;
data = input.data;
time = input.data(:,1);
startoffset = time(1);
flag = 0;

for walksectioncount = 1:length(walksection)
    startindex = max(find(time<=(walksection(walksectioncount).starttime+startoffset)));
    endindex = min(find(time>= (walksection(walksectioncount).endtime+startoffset)));
%     [walksectioncount startindex endindex]
    stridesectionleft = groupstrides(data,startindex,endindex,'left',40);
    stridesectionright = groupstrides(data,startindex,endindex,'right',40);
    leftsteps = 0; rightsteps = 0 ; 
    if length(stridesectionleft) == 0 ||length(stridesectionright) == 0;
    else
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
         for j = 1: length(allsection.leftankleindex)-1
                    % calculate symmetry
                    rightindexstart  = allsection.rightankleindex(j);
                    rightindexend = allsection.rightankleindex(j+1);
%                     if (rightindexend> rightindexstart) ||rightindexend>length(data)
%                         [rightindexstart rightindexend length(data)]
%                         continue;
%                     end
%                     [rightindexstart rightindexend walksectioncount]
                    rightswinglen = similarityscore(righttemplate.data(:,5:7),data(rightindexstart:rightindexend,5:7));

                    leftindexstart = allsection.leftankleindex(j);
                    leftindexend = allsection.leftankleindex(j+1);
                    leftswinglen = similarityscore(lefttemplate.data(:,2:4),data(leftindexstart:leftindexend,2:4));

                    symmetry(j) = leftswinglen/rightswinglen;
                    if j>1 && symmetry(j)<0
                        symmetry(j) = symmetry(j-1);
                    end
                    time(j) = (allsection.leftankleindex(j+1) - allsection.leftankleindex(j))/40;
                    cadence(j) = 2*60/time(j);
                    speed(j) = para(1)*time(j)+para(2);
                    if speed(j)<0
                        cadence(j) = -1;
                    end
                    stridelen(j) = speed(j)*60*2/cadence(j);

                    indexoutput = [indexoutput;rightindexstart];
                    cadoutput = [cadoutput;cadence(j)];
                    speedoutput = [speedoutput;speed(j)];
                    stridelenoutput = [stridelenoutput;stridelen(j)];
                    symmetryoutput = [symmetryoutput;symmetry(j)];    
         end 
     end            
end
ymd = input.header{1}.start_date;
hms = input.header{1}.start_time;
starttime = [ymd';hms'];
[indexvec indexstr] = TimeInterpret(starttime, startoffset, indexoutput,samplerate);

%% generate txt files
savefilename = [];
savefilename = [datapath '/' 'dailyprocess_','realtimeresultwithratio'];
fid = fopen(savefilename,'w');
validind = find(speedoutput>0.1);
ind = find(cadoutput>0);
fprintf(fid,'number of steps is %d, total distance is %f\n',numofsteps,sum(stridelenoutput(ind)));
fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',max(speedoutput),mean(speedoutput(validind)),min(speedoutput(validind)));
for jj = 1:length(cadoutput)
    if cadoutput(jj)<0 
    else       
        fprintf(fid,'%s\t%f %f %f %f\n',indexstr(jj,:),cadoutput(jj),speedoutput(jj),stridelenoutput(jj),symmetryoutput(jj));
    end
end