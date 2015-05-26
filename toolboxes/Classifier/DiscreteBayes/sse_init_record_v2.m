function record = init_record_v2(class_info,feature)

record = cell(length(class_info),length(feature));
for k=1:length(class_info)
    for p=1:length(feature)
%         record{k,p} = zeros(1,length(feature{p}.threshold)+1);
        record{k,p} = zeros(1,feature{p}.numThreshold+1);
    end
end