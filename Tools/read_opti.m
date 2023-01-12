function [rawData,isLoss,numLoss]=read_opti(fileName,timeLength)

%%% This script is used to read the .csv file that records 3D coordinates
%%% data produced by OptiTrack (for single user)

INDEX_COLUMN=[7:9,26:28,33:35,52:54,59:61,75:77,88:90,101:103,108:110,124:126,137:139,150:152,157:159,173:175,186:188,199:201,212:214,225:227,238:240];
sampleRate=120;
numSamples=timeLength*sampleRate;
isLoss=0;
numLoss=0;

rawData = csvread(fileName,7,0);
rawData=rawData(:,INDEX_COLUMN);

%Check for Packet Loss
for i=1:size(rawData,2)
    if rawData(1,i)==0 || rawData(end,i)==0
        isLoss=1;
        rawData=zeros(numSamples,19*3);
        return
    end
end

% Interpolation
for i=1:size(rawData,2)
    for j=1:size(rawData,1)
        if rawData(j,i)==0
            numLoss=numLoss+1;
            num=1;
            for k=j+1:size(rawData,1)
                if rawData(k,i)==0
                    num=num+1;
                    numLoss=numLoss+1;
                else
                    next=rawData(k,i);
                    nInterp = 1:(1/(num+1)):2;
                    index=1:2;
                    num_interp=interp1(index,[last,next],nInterp,'linear');
                    rawData(j:j+num-1,i)=num_interp(2:end-1);
                    break;
                end
            end
        else
            last=rawData(j,i);
        end
    end
end
% Time Complement
if length(rawData)<numSamples
    last=rawData(end,:);
    for i=1:numSamples-length(rawData)
        rawData=[rawData;last];
    end
end
% Unit Conversion (m)
rawData=rawData/1000;
end