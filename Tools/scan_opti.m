function [ files ] = scan_opti( rootDir )

%%% This script is used to read the .csv file that records 3D coordinates
%%% data produced by OptiTrack

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
            if strcmp(fileList(i).name(end-2:end),'csv')==0
                continue;
            end
            full_name=[rootDir,fileList(i).name];
            cntpic=cntpic+1;
            files(cntpic)={full_name};
        else
            files=[files,scan_opti([rootDir,fileList(i).name])];
        end
    end
end

end