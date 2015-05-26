% match right ankle and left ankle's sections into the same section
% to improve by determining the range
function allsection = matchsection(leftanklesection,rightanklesection)
if length(leftanklesection) == 0 || length(rightanklesection) == 0
    allsection = [];
    return;
end
i = 0; 
allsection = [];
for n = 1:length(leftanklesection)
    if length(leftanklesection(n).index)<3
        continue;
    end
    lenleft = length(leftanklesection(n).index);
    for m = 1:length(rightanklesection)
        if length(rightanklesection(m).index)<3
            continue;
        end
        lenright = length(rightanklesection(m).index);
        if (rightanklesection(m).index(lenright)<=leftanklesection(n).index(lenleft) && rightanklesection(m).index(1)<=leftanklesection(n).index(1) && rightanklesection(m).index(lenright)>leftanklesection(n).index(1) )||...
                (rightanklesection(m).index(lenright)>=leftanklesection(n).index(lenleft) && rightanklesection(m).index(1)>=leftanklesection(n).index(1) && rightanklesection(m).index(1)<leftanklesection(n).index(lenleft))||...
                (rightanklesection(m).index(lenright)>=leftanklesection(n).index(lenleft) && rightanklesection(m).index(1)<=leftanklesection(n).index(1))||...
                (rightanklesection(m).index(lenright)<=leftanklesection(n).index(lenleft) && rightanklesection(m).index(1)>=leftanklesection(n).index(1) )
            i = i + 1; 
            len = min(length(rightanklesection(m).index),length(leftanklesection(n).index));
            allsection(i).leftankleindex = leftanklesection(n).index(1:len);
            allsection(i).rightankleindex = rightanklesection(m).index(1:len);
            
        end
    end
end