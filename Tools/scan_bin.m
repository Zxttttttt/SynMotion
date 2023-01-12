function [ files ] = scan_bin( rootDir )

%%% This script is used to serach the .bin file that records raw binary data
%%% data produced by FMCW radar

files={};
if rootDir(end)~='/'
    rootDir=[rootDir,'/'];
end
fileList=dir(rootDir); 
n=length(fileList);
cntpic=0;
for i=1:n
    if strcmp(fileList(i).name,'.')==1||strcmp(fileList(i).name,'..')==1
        continue;
    else
        fileList(i).name;
        if ~fileList(i).isdir 
            if strcmp(fileList(i).name(end-2:end),'bin')==0
                continue;
            end
            full_name=[rootDir,fileList(i).name];
            cntpic=cntpic+1;
            files(cntpic)={full_name};
        else
            files=[files,scan_bin([rootDir,fileList(i).name])];
        end
    end
end

end