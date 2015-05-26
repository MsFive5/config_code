function countfile = writefilewithoutratio(path,dirname,filestring,indexstart,indexend,countfile,time,para)
    normalcoeff = 2.3148e-05/2;
    timestart = datenum(time(indexstart).string);
    timeend = datenum(time(indexend).string);
    
    if (timeend-timestart)<=59*normalcoeff
        filename = [path '/' dirname '/' filestring 'segdata' num2str(countfile)];
        fid = fopen(filename,'w');        
        fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',max(para(indexstart:indexend,2)),mean(para(indexstart:indexend,2)),min(para(indexstart:indexend,2)));
        for m = indexstart:indexend
            fprintf(fid,'%s\t%f %f %f \n',time(m).string,para(m,1),para(m,2),para(m,3));
        end
        fclose(fid);
        countfile = countfile + 1;
    else
        while(1)
            filename = [path '/' dirname '/' filestring 'segdata' num2str(countfile)];
            fid = fopen(filename,'w');
            if (timeend-timestart)<=70*normalcoeff
                fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',max(para(indexstart:indexend,2)),mean(para(indexstart:indexend,2)),min(para(indexstart:indexend,2)));
                for m = indexstart:indexend
                    fprintf(fid,'%s\t%f %f %f \n',time(m).string,para(m,1),para(m,2),para(m,3));
                end
                fclose(fid);
                countfile = countfile + 1;
                return;
            end   
            
            for j = 1:length(time)
                timeindex(j) = time(j).index;
            end
            timeindex = timeindex*normalcoeff;
            currentend = min(find((timeindex-datenum(time(indexstart).string)-59*normalcoeff)>0));
            fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',max(para(indexstart:indexend,2)),mean(para(indexstart:indexend,2)),min(para(indexstart:indexend,2)));          
            for m = indexstart:currentend
                fprintf(fid,'%s\t%f %f %f \n',time(m).string,para(m,1),para(m,2),para(m,3));
            end           
            
            fclose(fid);
            countfile = countfile + 1;
            indexstart = currentend+1;
            if indexstart>indexend
                return;
            end
            timestart = datenum(time(indexstart).string);
            if (timeend-timestart)<=59*normalcoeff
                filename = [path '/' dirname '/' filestring 'segdata' num2str(countfile)];
                fid = fopen(filename,'w');
                fprintf(fid,';max speed is %f, average speed is %f, slowest speed is %f\n',max(para(indexstart:indexend,2)),mean(para(indexstart:indexend,2)),min(para(indexstart:indexend,2)));
                for m = indexstart:indexend
                    fprintf(fid,'%s\t%f %f %f \n',time(m).string,para(m,1),para(m,2),para(m,3));
                end             
                
                fclose(fid);
                countfile = countfile + 1;  
                return;                
            end 
            
        end
    end
    
    

