function [totalHeatmap] = fft_2d(filePath,timeLength)

%%% This function is used to generate 2D heatmaps
%%% from raw FMCW data

nAdcSamples = 256;
nChirps = 128; % number of chirps in one frame
frameRate=20;
chirpCount=timeLength*frameRate*nChirps;

rawRadarData=read1443Data(filePath);


tx1Data=zeros(4,timeLength*frameRate*nChirps*nAdcSamples);
tx2Data=zeros(4,timeLength*frameRate*nChirps*nAdcSamples);
for i=1:chirpCount
    tx1Data(:,1+(i-1)*nAdcSamples:nAdcSamples*i)=rawRadarData(:,1+(i-1)*nAdcSamples*2:nAdcSamples+(i-1)*nAdcSamples*2);
    tx2Data(:,1+(i-1)*nAdcSamples:nAdcSamples*i)=rawRadarData(:,nAdcSamples+1+(i-1)*nAdcSamples*2:nAdcSamples*2+(i-1)*nAdcSamples*2);

end

rawRadarData=[tx2Data;tx1Data];

clear Tx1_data
clear Tx2_data

denoisedRadarData=zeros(8,(timeLength*frameRate-1)*nChirps*nAdcSamples);
for i=1:timeLength*frameRate-1
    denoisedRadarData(:,1+(i-1)*nAdcSamples*nChirps:nAdcSamples*nChirps*i)=rawRadarData(:,1+i*nAdcSamples*nChirps:(i+1)*nAdcSamples*nChirps)-rawRadarData(:,1+(i-1)*nAdcSamples*nChirps:(i)*nAdcSamples*nChirps);
end

totalHeatmap=zeros(timeLength*frameRate-1,nAdcSamples/2,nChirps);
for i=1:timeLength*frameRate-1
    thisChirp=denoisedRadarData(:,1+(i-1)*nAdcSamples*nChirps:nAdcSamples+(i-1)*nAdcSamples*nChirps);
    thisChirp=thisChirp.';
    thisHeatmap=fft2(thisChirp,nAdcSamples,nChirps);
    thisHeatmap=fftshift(thisHeatmap);
    thisHeatmap=abs(thisHeatmap);
    thisHeatmap=thisHeatmap(129:end,:);
    thisHeatmap(end-20:end,:)=0;

    m=max(max(thisHeatmap));
    [row,colomn]=find(thisHeatmap==m);
    thisHeatmap(1:row-10,:)=0;
    thisHeatmap(row+10:end,:)=0;
    thisHeatmap=rescale(thisHeatmap);
    thisHeatmap(thisHeatmap<0.05)=0;
    thisHeatmap=rescale(thisHeatmap);
    totalHeatmap(i,:,:)=thisHeatmap;
end
end

