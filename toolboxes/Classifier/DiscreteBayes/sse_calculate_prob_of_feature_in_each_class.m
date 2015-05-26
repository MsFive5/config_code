function [probList,record]=calculate_prob_of_feature_in_each_class( ...
            measure, feature, class_info, record, class, val_vec)
% probList is a matrix such that
% P(i,j) = Prob of measure i given class j.
        
probList = zeros(length(measure),length(class_info));
% for k=1:length(measure)
%     f_link      = measure{k}.link;
for k=1:length(feature)
    f_link      = k;    
    threshold   = feature{f_link}.threshold;
    value       = val_vec(f_link);
    
    % Find the bin number for this feature value.
    idx = find(threshold>=value,1,'first');
    if(isempty(idx))
       idx = length(threshold)+1; 
    end
    [prob, record] = aux_calculate_prob( ...
         class, class_info, f_link, record, idx);
%      [prob, record] = aux_calculate_prob_v2( ...
%          class, feature, f_link, record, idx);
     for p=1:length(measure)
        if(measure{p}.link==f_link)
            probList(p,:) = prob;
            break;
        end
     end
end

% calculate prob of a feature for each given class.
function [prob, record] = aux_calculate_prob_v2( ...
         class, feature, f_link, record, idx)

prob = feature{f_link}.prob(:,idx);
if(class~=0)
    record{class,f_link}(idx) = record{class,f_link}(idx) + 1;
end


% calculate prob of a feature for each given class.
function [prob, record] = aux_calculate_prob( ...
         class, class_info, f_link, record, idx)

prob = zeros(1,length(class_info));
for k=1:length(class_info)
    prob(k) = class_info{k}.prob(f_link,idx);
    if(class ~= 0)        
        record{class,f_link}(idx) = record{class,f_link}(idx) + 1;
%         record(class).corr.low = record(class).corr.low + 1;
    end
end
