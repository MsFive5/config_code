% template match process
function [label,position,stdvalue,distance] = templateMatch2(input,template, configVal)
label = zeros(1, length(input));
position = 0; 
stdvalue = 0; 
distance = 1e4;
if length(input) < length(template)
    return;
end
templatelen = length(template);
[inputlen,inputcol] = size(input);
distance = 1e5*ones(1,inputlen);
position = zeros(1,inputlen);
label = zeros(1,inputlen);
stdvalue = [];
datax = input(:,1);
datay = input(:,2);
dataz = input(:,3);

wl = templatelen; 
% ws = 5; 
ws = round(0.5*wl); % Celia updated on 12/07/14
nz = fix((inputlen-wl)/ws)+1;
c1=(1:wl)';
cnz=repmat(c1,1,nz); % vertical vector 1:wl repeated horizontally
l1=0:ws:(nz-1)*ws;
lnz=repmat(l1, wl,1); % horizontal vector spaced by ws repeated vertically
indexmatrix = cnz+ lnz;
matrixx = datax(indexmatrix); % sum of cnz+lnz gives me the matrix indexes
matrixy = datay(indexmatrix);
matrixz = dataz(indexmatrix);

stdarray = std(matrixx(1:wl,:))+std(matrixy(1:wl,:)) + std(matrixz(1:wl,:));
columnnum = find(stdarray>0.3);

for n = 1:length(columnnum)
    [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1)-mean(template(:,1)),matrixx(:,columnnum(n))-mean(matrixx(:,columnnum(n))),0);
    [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2)-mean(template(:,2)),matrixy(:,columnnum(n))-mean(matrixy(:,columnnum(n))),0);
    [Dist3,temp,temp,temp,temp,e4temp] = dtw(template(:,3)-mean(template(:,3)),matrixz(:,columnnum(n))-mean(matrixz(:,columnnum(n))),0);
    currentdistance = Dist1 + Dist2 + Dist3;
%     if currentdistance <= 1/2*(templatelen)
    if currentdistance <= configVal * (templatelen)
        label(indexmatrix(1,columnnum(n)):indexmatrix(1,columnnum(n))+60) = 1; 
        position(indexmatrix(1,columnnum(n))) = 1;
    end
end 


% for n = 1:5:inputlen-max(templatelen,40)
%     len = 40;
%     value = std(input(n:n+len-1,1)) + std(input(n:n+len-1,2))+ std(input(n:n+len-1,3));
%     stdvalue = [stdvalue;value];
%     if value < 0.5
%         continue;
%     end
%     [Dist1,temp,temp,temp,temp,temp] = dtw(template(:,1),input(n:n+templatelen-1,1)-mean(input(n:n+templatelen-1,1)),0);
%     [Dist2,temp,temp,temp,temp,temp] = dtw(template(:,2),input(n:n+templatelen-1,2)-mean(input(n:n+templatelen-1,2)),0);
%     [Dist3,temp,temp,temp,temp,e4temp] = dtw(template(:,3),input(n:n+templatelen-1,3)-mean(input(n:n+templatelen-1,3)),0);
%     currentdistance = Dist1 + Dist2 + Dist3;
%     distance(n) = currentdistance;
%     if currentdistance <= templatelen
%         label(n:n+60) = 1;
%         position(n) = 1;
%     end
% end
