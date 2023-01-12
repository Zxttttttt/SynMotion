function [vertCoordinate] = reform(rawData,nVerts,time)

RATE=120;
vertCoordinate = zeros(nVerts,time*RATE,3);
for i=1:nVerts
    vertCoordinate(i,:,1)= rawData(1:time*RATE,1+(i-1)*3);
    vertCoordinate(i,:,2)= rawData(1:time*RATE,2+(i-1)*3);
    vertCoordinate(i,:,3)= rawData(1:time*RATE,3+(i-1)*3);
end

end