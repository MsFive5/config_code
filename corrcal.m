function [corrall,replabel] = corrcal(input,flag)
data = input;
datax = input(:,1);
datay = input(:,2);
dataz = input(:,3);

corrall = [];
stdall = [];
replabel = zeros(1,length(input));
inputlen = length(data);

wl = 40;
ws = 1; 
nz = fix((inputlen-wl)/ws)+1;
c1=(1:wl)';
cnz=repmat(c1,1,nz); % vertical vector 1:wl repeated horizontally
l1=0:ws:(nz-1)*ws;
lnz=repmat(l1, wl,1); % horizontal vector spaced by ws repeated vertically
indexmatrix = cnz+ lnz;
matrixx = datax(indexmatrix); % sum of cnz+lnz gives me the matrix indexes
matrixy = datay(indexmatrix);
matrixz = dataz(indexmatrix);

for n = 1:size(matrixx,2) % how many columns are there 
    currentvalue = corr2(matrixx(1:wl,n),matrixz(1:wl,n));
    corrall = [corrall;currentvalue];
end

% for n = 1:length(input)-40
%     currentframe = data(n:n+40,:);
%     currentvalue = corr2(currentframe(:,1),currentframe(:,3));
%     corrall = [corrall;currentvalue];
% end


matrixx = [];
matrixy = [];
matrixz = [];
colunmlen = fix(inputlen/80);
matrixx = reshape(datax(1:colunmlen*80),80,colunmlen);
matrixy = reshape(datay(1:colunmlen*80),80,colunmlen);
matrixz = reshape(dataz(1:colunmlen*80),80,colunmlen);
matrixreplabel = reshape(replabel(1:colunmlen*80),80,colunmlen);

corrcolumnlen = fix(length(corrall)/80);
correlationmatrix = reshape(corrall(1:corrcolumnlen*80),80,corrcolumnlen);

stdarray = std(matrixx(1:80,:))+std(matrixy(1:80,:)) + std(matrixz(1:80,:));
columnnum = find(stdarray>0.02);
for n = 1:length(columnnum)
    if std(matrixy(1:80,columnnum(n)))>std(matrixx(1:80,columnnum(n))) && std(matrixy(1:80,columnnum(n)))>std(matrixz(1:80,columnnum(n))) && ...
            mean(matrixy(1:80,columnnum(n)))<mean(matrixx(1:80,columnnum(n))) && mean(matrixy(1:80,columnnum(n)))<mean(matrixz(1:80,columnnum(n)))
        if columnnum(n)>size(correlationmatrix,2)
            break;
        end
        poscorrnum = length(find(correlationmatrix(1:80,columnnum(n))>0));
        negcorrnum = length(find(correlationmatrix(1:80,columnnum(n))<0));
        if flag == 1
            if negcorrnum/poscorrnum>15
                matrixreplabel(1:80,columnnum(n)) = 1;
            end
        elseif flag == 1
            if poscorrnum/negcorrnum>15
                matrixreplabel(1:80,columnnum(n)) = 1;
            end
        end
    end
end
replabel = reshape(matrixreplabel,1,[]);
% for n = 1:80:length(corrall)-80 %check every 1 seconds
%     stdvalue = std(input(n:n+80,1))+std(input(n:n+80,2))+std(input(n:n+80,3));
%     stdall = [stdall;stdvalue];
%     if stdvalue<0.02
%     elseif stdvalue>0.02 && (std(input(n:n+80,2))>std(input(n:n+80,1))) && (std(input(n:n+80,2))>std(input(n:n+80,3))) && ...
%             (mean(input(n:n+80,2)) < mean(input(n:n+80,1)))&& (mean(input(n:n+80,2)) < mean(input(n:n+80,3)))
%         poscorrnum = length(find(corrall(n:n+79)>0));
%         negcorrnum = length(find(corrall(n:n+79)<0));
%         if flag == -1
%             if negcorrnum/poscorrnum>15 
%                 replabel(n:n+79) = 1;
%             end  
%         elseif flag == 1
%             if poscorrnum/negcorrnum>15
%                 replabel(n:n+79) = 1;
%             end            
%         end
%     end
% end