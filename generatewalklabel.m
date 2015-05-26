%generate walklabel
function finalwalking = generatewalklabel(input,label,walksection,NBoutput,path)
padzerolen= floor(NBoutput.starttime);
% NBoutput.classification = [zeros(1,padzerolen) NBoutput.classification];

finalwalking = NBoutput.classification;
% finalwalking = label(1:40:length(label));
offset = input.data(1,1);
if length(find(NBoutput.classification==1)) == 0 
    finalwalking = zeros(1,length(finalwalking)); 
    walksectionout = [];
    return;
end
% input.data(:,1) = input.data(:,1) - offset + 1;  
for n = 1:length(walksection)
   starttime = input.data(walksection(n).startindex,1)+1-offset;
   if floor(starttime)<1
       starttime = 1;
   end
   if  walksection(n).endindex>= length(input.data)
       endtime = input.data(length(input.data),1)+1-offset;
   else
       endtime = input.data(walksection(n).endindex,1)+1-offset;       
   end
   if length(finalwalking)<=endtime   
       endtime = length(finalwalking);
   end
   if length(find(finalwalking(floor(starttime):floor(endtime)) == 1))>=1
       finalwalking(floor(starttime):floor(endtime)) = 1; 
%    elseif length(find(finalwalking(floor(starttime):floor(endtime)) == 1))<1 && (endtime-starttime)>4
%        finalwalking(floor(starttime):floor(endtime)) = 0;
   end
%    if (endtime-starttime)<=2
%        finalwalking(floor(starttime):floor(endtime)) = 0;
%    end
end
