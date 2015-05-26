function cur_prob = calculate_prob_of_each_class(probList, class_info)

cur_prob = zeros(1,length(class_info));

for k = 1:length(cur_prob)
    prod_prob   = prod(probList(:,k));
    cur_prob(k) = class_info{k}.apriori * prod_prob;
end