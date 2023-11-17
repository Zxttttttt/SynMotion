function [retBin] = findbin(rootDir)

%%% This script is used to search .bin files that record raw binary data
%%% collected by FMCW radars

retBin={};
if rootDir(end)~='/'
    rootDir=[rootDir,'/'];
end
fileList=dir(rootDir);
cnt=0;
for iFile=1:length(fileList)
    if strcmp(fileList(iFile).name,'.')==1||strcmp(fileList(iFile).name,'..')==1
        continue;
    else
        fileList(iFile).name;
        if ~fileList(iFile).isdir
            if strcmp(fileList(iFile).name(end-2:end),'bin')==0
                continue;
            end
            full_name=[rootDir,fileList(iFile).name];
            cnt=cnt+1;
            retBin(cnt)={full_name};
        else
            retBin=[retBin,findbin([rootDir,fileList(iFile).name])];
        end
    end
end

end