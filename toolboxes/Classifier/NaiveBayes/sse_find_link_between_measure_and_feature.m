function measure = find_link_between_measure_and_feature(feature, measure)

for k=1:length(feature)
    feature_name = feature{k}.id;
    for p=1:length(measure)
        measure_name = measure{p}.id;
        if(strcmp(feature_name,measure_name))
            measure{p}.link = k;
            break;
        end
    end
end