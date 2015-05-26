function [probList,record]=sse_determine_threshold_and_probf_for_each_class( ...
            feature, class_info, training_record, class, val_vec)
        
tmp = val_vec(:);
tmp = [class; tmp];
training_record(end,:) = tmp;
