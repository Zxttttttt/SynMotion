function [vertCoordinate] = reform(rawData,nVerts,timeLength)

%%% This function is used to change the format of OptiTrack rawdata:
%%% [vert,data sample,axis]

sampleRate=120;
vertCoordinate = zeros(nVerts,timeLength*sampleRate,3);
for i=1:nVerts
    vertCoordinate(i,:,1)= rawData(1:timeLength*sampleRate,1+(i-1)*3);
    vertCoordinate(i,:,2)= rawData(1:timeLength*sampleRate,2+(i-1)*3);
    vertCoordinate(i,:,3)= rawData(1:timeLength*sampleRate,3+(i-1)*3);
end

end