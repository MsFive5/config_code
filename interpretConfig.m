function configStruc = interpretConfig(configFile)
configStruc{1}.field = [];
configStruc{1}.value = [];
fid = fopen(configFile);

tline = fgetl(fid);
n = 1; 
while ischar(tline)
    disp(tline);
    if strcmp(tline(1), '%')
        tline = fgetl(fid);
    end
    
    a = textscan(tline,'%s\t%s');
    field = a{1};
    value = a{2};
    configStruc{n}.field = field; 
    configStruc{n}.value = value; 
    n = n + 1; 
    tline = fgetl(fid);        
end

fclose(fid);