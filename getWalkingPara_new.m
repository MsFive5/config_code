%%
function [para,trainingsection,vector1,vector2] = getWalkingPara_new(input,trainingsection,sensorinfo,samplerate,datapath)
boutlength = sensorinfo.boutlength;
hemiside = sensorinfo.hemiside;

for n = 1:length(trainingsection)
    if trainingsection(n).valid == 1
        % use the combination of x and z axis
        if strcmp(hemiside,'1 ') == 1
                pp1 = input.data(trainingsection(n).start:trainingsection(n).end,5);
                pp2 = input.data(trainingsection(n).start:trainingsection(n).end,7);  
        else
                pp1 = input.data(trainingsection(n).start:trainingsection(n).end,2);
                pp2 = input.data(trainingsection(n).start:trainingsection(n).end,4);    
        end
        pp3 = pp1.^2+pp2.^2;
        ind = find(pp3>0.2);
        ind2 = find(pp3>0.5);
        startindex = ind(1);
        endindex = ind(length(ind));
        indmean = find(pp3>1); 
%         if mean(pp3(indmean))<=1.5
%             windowsize = 65;
        for nn = 1:length(pp3)
            if pp3(nn)>=5
                pp3(nn)=5;
            end
        end
        
        if mean(pp3(indmean)) <= 1.8 && mean(pp3(ind2))<0.5
            windowsize = 60;
        elseif mean(pp3(indmean)) <= 2 && mean(pp3(ind2))>=0.5
            windowsize = 50;
        elseif mean(pp3(indmean)) >2 && mean(pp3(indmean)) <= 2.5
            windowsize = 45;
        elseif mean(pp3(indmean)) >2.5 && mean(pp3(indmean)) <= 3.5
            windowsize = 40;
        elseif mean(pp3(indmean)) >3.5 && mean(pp3(indmean)) <= 4
            windowsize = 35;            
        else
            windowsize = 30;
        end
        [aa,bb] = lmax_pw(pp3(startindex:endindex),windowsize);
        
        diffbb = diff(bb);
        ind2remove = [];
        for m = 1:length(bb)
            if aa(m)<0.2
                ind2remove = [ind2remove;m];
            end
        end
        %% remove nearby points
        pptest = pp3(startindex:endindex);
        for m = 1:length(diffbb)
            if diffbb(m)<=20
                if pptest(bb(m))>pptest(bb(m+1))
                    ind2remove = [ind2remove;m+1];
                else
                    ind2remove = [ind2remove;m];
                end
                
            end
        end
        bb=bb(setdiff(1:length(bb),ind2remove));
        ind2remove = [];
        %% supress non-dominant peaks
        gapdis = diff(bb)/mean(diff(bb));
        initialdis = mean(diff(bb));
        while(length(find(gapdis<0.6))>=1)          
            ind2remove = find(gapdis<0.6);   
            bb=bb(setdiff(1:length(bb),ind2remove));
            gapdis = diff(bb)/initialdis;  
            ind2remove = [];
        end
        
        %bb=bb(setdiff(1:length(bb),ind2remove));
        bb = startindex+trainingsection(n).start-1 + bb -1 ;
        trainingsection(n).stridepoint = bb;
    end
end
vector1 = [];
vector2 = [];
stridenum = [];
for n = 1:length(trainingsection)
    if trainingsection(n).valid == 1
        array = trainingsection(n).stridepoint;
        stridenum = [stridenum;length(array)];
        diffvec = diff(array);
        vector1 = [vector1;mean(diffvec)];
        %time = (array(length(array))-array(1))/samplerate;
        time = (trainingsection(n).end-trainingsection(n).start)/samplerate;
        trainingsection(n).speed = str2num(boutlength)*0.3048/time;
        vector2 = [vector2;trainingsection(n).speed];
    end
end
% add code later to deal with the training time less than 3

if length(vector1) == 2
    if abs(vector1(1)-vector1(2))<0.05*40
        para = polyfit(vector1(1)/samplerate,vector2(1),1);     
        vector1 = vector1(1);
        vector2 = vector2(1);
    else
        para = polyfit(vector1/samplerate,vector2,1);  
    end
else
    para = polyfit(vector1/samplerate,vector2,1);    
end
save([datapath '/' 'training_para.mat'],'para','vector1','vector2');

medianstridenum = round(median(stridenum));
[diffvalue,medianindex] = min(abs(stridenum-medianstridenum));
medianstridenum = stridenum(medianindex(1));
index = find(stridenum == medianstridenum,1,'first');
count = 0; 
for n = 1:length(trainingsection)
    if trainingsection(n).valid == 1
        count = count + 1; 
        if count == index
            medianpoint = round(median(trainingsection(n).stridepoint));
            [diffvalue,medianindex] = min(abs(trainingsection(n).stridepoint-medianpoint));
            medianpoint = trainingsection(n).stridepoint(medianindex(1));
            index = find(trainingsection(n).stridepoint == medianpoint);
            left = input.data(trainingsection(n).stridepoint(index):trainingsection(n).stridepoint(index+1),2:4);
            right = input.data(trainingsection(n).stridepoint(index):trainingsection(n).stridepoint(index+1),5:7);
%             fullstridetemplate(n).left = left; 
%             fullstridetemplate(n).right = right; 
            save([datapath '/' 'fullstridetemplate'],'left','right');
%             save([datapath '/' 'fullstridetemplate'],'fullstridetemplate');
        end
    end
end
