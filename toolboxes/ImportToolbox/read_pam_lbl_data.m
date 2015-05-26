function [mdata,header]=read_pam_lbl_data(filename)
    DEBUG_FLAG = 0;

    mdata = [];
    header = [];

    fid=fopen(filename);
    for k=1:2
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        %disp(tline)

        switch k
            case 1
                if(DEBUG_FLAG)
                    disp(tline);
                end
                %;MATFile=DATA-001.MAT
                [A, count, errmsg, nextindex] = ...
                sscanf(tline,';MATFile=%s' );
                header.MATFile = A;
            case 2
                if(DEBUG_FLAG)
                    disp(tline);
                end
        end
    end
    limits = [];
    done = 0;
    while ~done
        tline = fgetl(fid);
        if ~ischar(tline)
            done = 1;
        end
        if(~done)
            [class,region]=strtok(tline,'=');
            region = strtok(region,'=');
            mdata.class = class;
            mdata.region = eval(region);
            limits{end+1} = mdata;
        end
    end
    fclose(fid);
    finalData = [];
    for c1 = 1:length(limits)
        finalDataTemp = [];
        class = limits{c1}.class;
        r = [];
        r{1} = limits{c1}.region;
        for c2 = 1:length(limits)
            if((c2 ~= c1) && strcmp(class,limits{c2}.class))
                r{end+1} = limits{c2}.region;
            end
        end
        finalDataTemp.class = class;
        finalDataTemp.region = r{1};
        for l = 2:length(r)
            finalDataTemp.region = [finalDataTemp.region r{l}];
        end
        found = 0;
        for l=1:length(finalData)
            if(strcmp(finalData{l}.class,class))
                found = 1;
            end
        end
        if(~found)
            finalData{end+1} = finalDataTemp;
        end
    end
    
    mdata = finalData;
