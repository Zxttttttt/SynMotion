function [retData,isLoss,nLoss]=readOpti(fileName,timeLength)

%%% This script is used to read .csv files that record 3D coordinates
%%% raw data collected by OptiTrack (for single user)

COLUMNS=[7:9,26:28,33:35,52:54,59:61,75:77,88:90,101:103,108:110,124:126,137:139,150:152,157:159,173:175,186:188,199:201,212:214,225:227,238:240];
sampleRate=120;
nSamples=timeLength*sampleRate;
isLoss=0;
nLoss=0;

retData = csvread(fileName,7,0);
retData=retData(:,COLUMNS);

%Check for Packet Loss
for iColumns=1:size(retData,2)
    if retData(1,iColumns)==0 || retData(end,iColumns)==0
        isLoss=1;
        retData=zeros(nSamples,19*3);
        return
    end
end

% Interpolation
for iColumns=1:size(retData,2)
    for iRows=1:size(retData,1)
        if retData(iRows,iColumns)==0
            nLoss=nLoss+1;
            num=1;
            for jRows=iRows+1:size(retData,1)
                if retData(jRows,iColumns)==0
                    num=num+1;
                    nLoss=nLoss+1;
                else
                    next=retData(jRows,iColumns);
                    nInterp = 1:(1/(num+1)):2;
                    index=1:2;
                    vInterp=interp1(index,[last,next],nInterp,'linear');
                    retData(iRows:iRows+num-1,iColumns)=vInterp(2:end-1);
                    break;
                end
            end
        else
            last=retData(iRows,iColumns);
        end
    end
end
% Time Complement
if length(retData)<nSamples
    last=retData(end,:);
    for iColumns=1:nSamples-length(retData)
        retData=[retData;last];
    end
end
% Unit Conversion (from mm to m)
retData=retData/1000;
end