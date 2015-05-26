function output = padZeros(input)
time = input(:,1);
diffTime = diff(time);
diffTimeInd = find(diffTime>50);

output = input;
% while(length(find(diffTime>25)))
%     diffTime = find(diff(time)>25);
%     padLength = floor(diffTime(1)/25); 
%     output = [input(1:diffTime(1),:); zeros(padLength, size(input,2));input(diffTime(1)+1:end,:)];
%     
% end

while(length(diffTimeInd))
    m = diffTimeInd(1);
    padLength = floor(diffTime(m)/25); 
    output = [output(1:m,:); zeros(padLength, size(input,2));output(m+1:end,:)];
    time = output(:,1);
    time(m+1:m+padLength) = (output(m,1)+25:25:output(m,1)+25+(padLength-1)*25)';
%     time = [output(1:m,1); (output(m,1)+25:25:output(m,1)+25+(padLength-1)*25)';output(m+1:end,1)];
    output(:,1) = time;
    diffTime = diff(time);
    diffTimeInd = find(diffTime>50);
    %padLength
end
time = time(1):25:time(1)+(length(output)-1)*25;
output(:, 1) = time;