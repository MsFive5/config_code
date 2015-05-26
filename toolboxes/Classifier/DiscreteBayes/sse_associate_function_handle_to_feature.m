function feature = associate_function_handle_to_feature(feature)

for k=1:length(feature)
    switch feature{k}.id
        case 'correlation'
            disp('Method is correlation')
        case 'stdevv'
            disp('Method is stdevv')
        case 'stdevh'
            disp('Method is stdevh')        
        case 'vhste'
            disp('Method is vhste')
        case 'vfratio'
            disp('Method is vfratio')
        case 'meanv'
            feature{k}.fn_handle = @sse_mean_v_fn;
        case 'meanh'
            feature{k}.fn_handle = @sse_mean_h_fn;
        case 'meant'
            feature{k}.fn_handle = @sse_mean_t_fn;
        case 'hfratio'
            disp('Method is hfratio') 
        case 'tfratio'
            disp('Method is tfratio') 
        case 'max_v'
            feature{k}.fn_handle = @sse_max_v_fn;
        case 'max_h'
            feature{k}.fn_handle = @sse_max_h_fn;
        case 'max_t'
            feature{k}.fn_handle = @sse_max_t_fn;
        otherwise
           fprintf('Error: %s function is not associated\n',...
                    feature{k}.id);
    end
end
