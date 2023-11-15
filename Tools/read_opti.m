function [raw_data,is_loss,n_loss]=read_opti(file_name,time_length)

%%% This script is used to read .csv files that record 3D coordinates
%%% raw data collected by OptiTrack (for single user)

i_columns=[7:9,26:28,33:35,52:54,59:61,75:77,88:90,101:103,108:110,124:126,137:139,150:152,157:159,173:175,186:188,199:201,212:214,225:227,238:240];
sample_rate=120;
n_samples=time_length*sample_rate;
is_loss=0;
n_loss=0;

raw_data = csvread(file_name,7,0);
raw_data=raw_data(:,i_columns);

%Check for Packet Loss
for i=1:size(raw_data,2)
    if raw_data(1,i)==0 || raw_data(end,i)==0
        is_loss=1;
        raw_data=zeros(n_samples,19*3);
        return
    end
end

% Interpolation
for i=1:size(raw_data,2)
    for j=1:size(raw_data,1)
        if raw_data(j,i)==0
            n_loss=n_loss+1;
            num=1;
            for k=j+1:size(raw_data,1)
                if raw_data(k,i)==0
                    num=num+1;
                    n_loss=n_loss+1;
                else
                    next=raw_data(k,i);
                    n_interp = 1:(1/(num+1)):2;
                    index=1:2;
                    value_interp=interp1(index,[last,next],n_interp,'linear');
                    raw_data(j:j+num-1,i)=value_interp(2:end-1);
                    break;
                end
            end
        else
            last=raw_data(j,i);
        end
    end
end
% Time Complement
if length(raw_data)<n_samples
    last=raw_data(end,:);
    for i=1:n_samples-length(raw_data)
        raw_data=[raw_data;last];
    end
end
% Unit Conversion (from mm to m)
raw_data=raw_data/1000;
end