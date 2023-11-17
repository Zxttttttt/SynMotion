function [retCsv] = findCsv(rootDir)

%%% This script is used to search .csv files that record 3D coordinates
%%% raw data collected by OptiTrack

retCsv={};
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
            if strcmp(fileList(iFile).name(end-2:end),'csv')==0
                continue;
            end
            full_name=[rootDir,fileList(iFile).name];
            cnt=cnt+1;
            retCsv(cnt)={full_name};
        else
            retCsv=[retCsv,findcsv([rootDir,fileList(iFile).name])];
        end
    end
end

end