function [final_val_vec, val_struct, features] = FeatureExtractor_v2(feature, header, processed_data)
    
    features = {};
%     final_val_vec = zeros(1,length(feature)*2);
    final_val_vec = [];
    val_struct = cell(1,size(processed_data.vertical,2));

    vertical    = processed_data.vertical;
    horizontal  = processed_data.horizontal;
    tangent     = processed_data.tangent;

    mean_v      = mean(vertical,1);
    mean_h      = mean(horizontal,1);
    mean_t      = mean(tangent,1);

    zm_vertical  = vertical   - repmat(mean_v,size(vertical,1),1);
    zm_horizontal= horizontal - repmat(mean_h,size(horizontal,1),1);
    zm_tangent   = tangent    - repmat(mean_t,size(tangent,1),1);

    periodstart = processed_data.periodstart;
    periodend   = processed_data.periodend;
    delta       = periodend - periodstart;

    fftSize = 1024;
    fft_threshold = 30;

    lmax_winSize = 5;

    vste = -1;
    hste = -1;
    tste = -1;

    val_vec = zeros(1,length(feature));

    for k=1:length(feature)
        vste = -1;
        hste = -1;
        tste = -1;
        feature_name = feature{k}.id;
        [tok, rem] = strtok(feature_name,'_');
        ind = 1;
        l = 0;
        while (ind <= length(header)) && (l == 0)
            if(strcmp(header{ind}.sensorName,tok))
                l=ind;
            end
            ind = ind + 1;
        end
        if l == 0
            %this sensor is not available
        else
            switch rem(2:end)
                %---------------------------------------------------------------
                % CORRELATION MEASURE
                %---------------------------------------------------------------
                case 'correlationxy'
                    val_vec(k) = abs(corr2(zm_vertical(:,l),zm_horizontal(:,l)));
                    val_struct{l}.(feature_name)=val_vec(k); 
                %---------------------------------------------------------------
                % STD MEASURE
                %---------------------------------------------------------------
                case 'stdevx'
                    val_vec(k) = std(zm_vertical(:,l));
                    val_struct{l}.(feature_name)=val_vec(k); 
                case 'stdevy'
                    val_vec(k) = std(zm_horizontal(:,l));   
                    val_struct{l}.(feature_name)=val_vec(k); 
                case 'stdevz'
                    val_vec(k) = std(zm_tangent(:,1));
                    val_struct{l}.(feature_name) = val_vec(k);
                case 'stdevxz'
                    val_vec(k) = std(zm_tangent(:,1))+std(zm_vertical(:,l));
                    val_struct{l}.(feature_name) = val_vec(k);
                %---------------------------------------------------------------
                % STE MEASURE
                %---------------------------------------------------------------   
                case 'xyste'
                    if(vste==-1)
                        vste = sse_ste_measure_fn( ...
                                    zm_vertical(:,l), lmax_winSize, delta);  
                    end 
                    if(hste==-1)    
                        hste = sse_ste_measure_fn( ...
                                    zm_horizontal(:,l), lmax_winSize, delta); 
                    end
                    val_vec(k) = vste - hste;    
                    val_struct{l}.(feature_name)=val_vec(k); 
                case 'xzyste'
                    if(vste==-1)
                        vste = sse_ste_measure_fn( ...
                                    zm_vertical(:,l), lmax_winSize, delta);  
                    end 
                    if(hste==-1)    
                        hste = sse_ste_measure_fn( ...
                                    zm_horizontal(:,l), lmax_winSize, delta); 
                    end
                    if(tste==-1)     
                        tste = sse_ste_measure_fn( ...
                        zm_tangent(:,l), lmax_winSize, delta); 
                    end
                    val_vec(k) = vste + tste - hste;    
                    val_struct{l}.(feature_name)=val_vec(k);                     
                case 'xste'
                    if(vste==-1)
                        vste = sse_ste_measure_fn( ...
                                    zm_vertical(:,l), lmax_winSize, delta);  
                    end
                    val_vec(k) = vste;   
                    val_struct{l}.(feature_name)=val_vec(k); 
                case 'yste'
                    if(hste==-1)    
                        hste = sse_ste_measure_fn( ...
                                    zm_horizontal(:,l), lmax_winSize, delta); 
                    end
                    val_vec(k) = hste;   
                    val_struct{l}.(feature_name)=val_vec(k);
                case 'zste'
                    if(tste==-1)     
                        tste = sse_ste_measure_fn( ...
                                    zm_tangent(:,l), lmax_winSize, delta); 
                    end
                    val_vec(k) = tste;
                    val_struct{l}.(feature_name)=val_vec(k);
                %---------------------------------------------------------------
                % MEAN MEASURE
                %---------------------------------------------------------------   
                case 'meanx'
                    val_vec(k) = mean_v(l);
                    val_struct{l}.(feature_name)=val_vec(k);
                case 'meany'
                    val_vec(k) = mean_h(l);
                    val_struct{l}.(feature_name)=val_vec(k);
                case 'meanz'
                    val_vec(k) = mean_t(l);
                    val_struct{l}.(feature_name)=val_vec(k);
                %---------------------------------------------------------------
                % F_RATIO MEASURE
                %---------------------------------------------------------------   
%                 case 'xfratio'
%                     [vfratio,vf] = sse_fratio_measure_fn(zm_vertical(:,l),...
%                                         fftSize, fft_threshold);
%                     val_vec(k) = vfratio;   
%                     val_struct{l}.(feature_name)=val_vec(k);
%                 case 'yfratio'
%                     [hfratio,hf] = sse_fratio_measure_fn(zm_horizontal(:,l),...
%                                         fftSize, fft_threshold);
%                     val_vec(k) = hfratio;
%                     val_struct{l}.(feature_name)=val_vec(k);
%                 case 'zfratio'
%                     [tfratio,tf] = sse_fratio_measure_fn(zm_tangent(:,l),...
%                                         fftSize, fft_threshold);
%                     val_vec(k) = tfratio; 
%                     val_struct{l}.(feature_name)=val_vec(k);
                %---------------------------------------------------------------
                % MAX MEASURE
                %---------------------------------------------------------------   
                case 'max_x'
                    val_vec(k) = max(vertical(:,l));
                    val_struct{l}.(feature_name)=val_vec(k);
                case 'max_y'
                    val_vec(k) = max(horizontal(:,l));
                    val_struct{l}.(feature_name)=val_vec(k);
                case 'max_z'
                    val_vec(k) = max(tangent(:,l));
                    val_struct{l}.(feature_name)=val_vec(k);
                %---------------------------------------------------------------
                % ERROR CHECKING
                %---------------------------------------------------------------   
                otherwise
                   fprintf('Error: %s function is not associated\n',...
                            feature_name);
            end
            if(l > 0)
                final_val_vec = [final_val_vec val_vec(k)];
%             if(isempty(final_val_vec))
%                 final_val_vec = val_vec;
%             else
%                 final_val_vec = [final_val_vec val_vec];
%             end
                features{end+1} = feature{k};
            end
        end
    end
    val_struct2 = {};
    for l=1:length(val_struct)
        if(~isempty(val_struct{l}))
            val_struct2{end+1} = val_struct{l};
        end
    end
    val_struct = val_struct2;
end

