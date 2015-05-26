function [label_state] = sse_consolidate_label_test(class_info,training_struct)

totSeg = 0;
for k=1:length(class_info)
    totSeg = totSeg + length(class_info{k}.start);
end
label_start   = zeros(2,totSeg);
label_end     = zeros(2,totSeg);
cnt = 0;
for k=1:length(class_info)
    class_name = class_info{k}.id;
    for l = 1:length(training_struct)
        if(strcmp(training_struct{l}.id,class_name))
            class_id = l;
        end
    end
    len = length(class_info{k}.start);
    tmp = [class_info{k}.start(:) ones(len,1)*class_id];
    label_start(:,cnt+(1:len)) = tmp';
    tmp = [class_info{k}.end(:) ones(len,1)*class_id];
    label_end(:,cnt+(1:len)) = tmp';
    cnt = cnt + len;
end
[dump,ind1] = sort(label_start(1,:),2);
[dump,ind2] = sort(label_end(1,:),2);
if(any(ind1~=ind2))
   fprintf('Error: The start and end time of the class labelling is wrong.\n');
end
label_state = [label_start(1,ind1);
               label_end(1,ind2);
               label_start(2,ind1);];
