function val_vec = sse_measure_fn(measure, feature, processed_data)

vertical    = processed_data.vertical;
horizontal  = processed_data.horizontal;
tangent     = processed_data.tangent;

mean_v      = mean(vertical);
mean_h      = mean(horizontal);
mean_t      = mean(tangent);

zm_vertical  = vertical   - mean_v;
zm_horizontal= horizontal - mean_h;
zm_tangent   = tangent    - mean_t;
                     
periodstart = processed_data.periodstart;
periodend   = processed_data.periodstart;
delta       = periodend - periodstart;

fftSize = 1024;
fft_thresold = 30;
            
lmax_winSize = 5;

vste = -1;
hste = -1;
tste = -1;

val_vec = zeros(1,length(measure));

for k=1:length(measure)
    feature_name = feature{measure{k}.link}.id;
    
    switch feature_name
        %---------------------------------------------------------------
        % CORRELATION MEASURE
        %---------------------------------------------------------------
        case 'correlation'
            val_vec(k) = abs(corr2(zm_vertical,zm_horizontal));
        %---------------------------------------------------------------
        % STD MEASURE
        %---------------------------------------------------------------
        case 'stdevv'
            val_vec(k) = std(zm_vertical);
            
        case 'stdevh'
            val_vec(k) = std(zm_horizontal);   
        %---------------------------------------------------------------
        % STE MEASURE
        %---------------------------------------------------------------   
        case 'vhste'
            if(vste==-1)
                vste = sse_ste_measure_fn( ...
                            zm_vertical, lmax_winSize, delta);  
            end 
            if(hste==-1)    
            	hste = sse_ste_measure_fn( ...
                            zm_horizontal, lmax_winSize, delta); 
            end
            val_vec(k) = vste - hste;           
        case 'vste'
            if(vste==-1)
                vste = sse_ste_measure_fn( ...
                            zm_vertical, lmax_winSize, delta);  
            end
            val_vec(k) = vste;            
        case 'hste'
            if(hste==-1)    
            	hste = sse_ste_measure_fn( ...
                            zm_horizontal, lmax_winSize, delta); 
            end
            val_vec(k) = hste;           
        case 'tste'
            if(tste==-1)     
            	tste = sse_ste_measure_fn( ...
                            zm_tangent, lmax_winSize, delta); 
            end
            val_vec(k) = tste;
        %---------------------------------------------------------------
        % MEAN MEASURE
        %---------------------------------------------------------------   
        case 'meanv'
            val_vec(k) = mean_v;
        case 'meanh'
            val_vec(k) = mean_h;
        case 'meant'
            val_vec(k) = mean_t;
        %---------------------------------------------------------------
        % F_RATIO MEASURE
        %---------------------------------------------------------------   
        case 'vfratio'
            [vfratio,vf] = sse_fratio_measure_fn(zm_vertical,...
                                fftSize, fft_threshold);
            val_vec(k) = vfratio;   
        case 'hfratio'
            [hfratio,hf] = sse_fratio_measure_fn(zm_horizontal,...
                                fftSize, fft_threshold);
            val_vec(k) = hfratio; 
        case 'tfratio'
            [tfratio,tf] = sse_fratio_measure_fn(zm_tangent,...
                                fftSize, fft_threshold);
            val_vec(k) = tfratio; 
        %---------------------------------------------------------------
        % MAX MEASURE
        %---------------------------------------------------------------   
        case 'max_v'
            val_vec(k) = max(vertical);
        case 'max_h'
            val_vec(k) = max(horizontal);
        case 'max_t'
            val_vec(k) = max(tangent);
        %---------------------------------------------------------------
        % ERROR CHECKING
        %---------------------------------------------------------------   
        otherwise
           fprintf('Error: %s function is not associated\n',...
                    feature_name);
    end
end


