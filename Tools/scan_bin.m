function [ files ] = scan_bin( root_dir )

%%% This script is used to search .bin files that records raw binary data
%%% collected by FMCW radars

files={};
if root_dir(end)~='/'
    root_dir=[root_dir,'/'];
end
file_list=dir(root_dir); 
cnt_pic=0;
for i=1:length(file_list)
    if strcmp(file_list(i).name,'.')==1||strcmp(file_list(i).name,'..')==1
        continue;
    else
        file_list(i).name;
        if ~file_list(i).isdir 
            if strcmp(file_list(i).name(end-2:end),'bin')==0
                continue;
            end
            full_name=[root_dir,file_list(i).name];
            cnt_pic=cnt_pic+1;
            files(cnt_pic)={full_name};
        else
            files=[files,scan_bin([root_dir,file_list(i).name])];
        end
    end
end

end