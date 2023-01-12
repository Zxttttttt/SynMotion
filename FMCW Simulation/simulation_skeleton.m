function[totalSignal,groundTruth,totalHeatmap]=simulation_skeleton(rawData,txArray,rxArray,nRepeat,timeLength,nChirps)

nAdcSamples = 256;
nFrames = timeLength*20;
nVerts = 19;
nBones=22;
sampleRate=120;
frameRate=20;
STICKS = [1,2;2,3;3,4;
    4,6;4,10
    6,7;7,8;8,9;
    10,11;11,12;12,13;
    1,14;1,17;
    14,15;15,16;
    17,18;18,19;
    2,14;2,17;
    6,3;10,3;
    4,5;];

rawData=rawData(1:sampleRate*timeLength,:);
vertCoordinateInterp=reform(rawData,nVerts,timeLength);
vertInitialState=vertCoordinateInterp(:,1,:);

boneLength=zeros(nBones,1);
for i=1:nBones
    num1=STICKS(i,1);
    num2=STICKS(i,2);
    length=(vertInitialState(num1,1)-vertInitialState(num2,1)).^2+(vertInitialState(num1,2)-vertInitialState(num2,2)).^2+(vertInitialState(num1,3)-vertInitialState(num2,3)).^2;
    length=sqrt(length);
    boneLength(i)=length;
end

TORSO_UNIT=1/0.8*0.25;
UL_UNIT=1/0.5*0.1/3;
LL_UNIT=0;%1/0.5*0.07;
FEET_UNIT=1/0.2*0.07;
UA_UNIT=1/0.45*2*0.05;
LA_UNIT=1/0.45*2*0.04;
% UA_UNIT=1/0.45*0.05;
% LA_UNIT=1/0.45*0.04;

radiusUnit=zeros(nBones,1);
radiusUnit([1,2,3,4,5,12,13,18,19,20,21],:)=TORSO_UNIT;
radiusUnit([14,16],:)=UL_UNIT;
radiusUnit([15,17],:)=LL_UNIT;
radiusUnit([6,9],:)=UA_UNIT;
radiusUnit([7,8,10,11],:)=LA_UNIT;
radius=radiusUnit.*boneLength;
radius(22)=0.2;
repeat=[];
for i=1:nRepeat
    repeat=[repeat;1];
end
radius=kron(radius,repeat);
boneLength=kron(boneLength,repeat);



vertCoordinate=reform(rawData,nVerts,timeLength);
vertCoordinateInterp = compute_interp(vertCoordinate,timeLength,nChirps);
groundTruth=vertCoordinateInterp;


nTx=size(txArray,1);
nRx=size(rxArray,1);
totalSignal=zeros(nTx*nRx,nAdcSamples*nFrames*nChirps);
antennaCount=1;
for i=1:nTx
    tx=txArray(i,:);
    for j=1:nRx
        rx=rxArray(j,:);
        [bone_distance,bone_angle] = compute_angle_distance(vertCoordinateInterp,tx,rx,nRepeat,STICKS);
        antennaSignal = zeros(1, nAdcSamples*nChirps*nFrames);
        for chirpCount = 1:nFrames*nChirps
            chirpDistance = bone_distance ((chirpCount-1)+1:chirpCount,:);
            chirpDistance=chirpDistance';
            chirpAngle = bone_angle ((chirpCount-1)+1:chirpCount,:);
            chirpAngle=chirpAngle';
            antennaSignal(1,(chirpCount-1)*nAdcSamples+1:chirpCount*nAdcSamples)= compute_signal(chirpDistance,chirpAngle,radius,boneLength);
        end
        totalSignal(antennaCount,:)=antennaSignal;
        antennaCount=antennaCount+1;
    end
end


totalSignalDenoised=zeros(nTx*nRx,(timeLength*frameRate-1)*nChirps*nAdcSamples);
for i=1:timeLength*frameRate-1
    totalSignalDenoised(:,1+(i-1)*nAdcSamples*nChirps:nAdcSamples*nChirps*i)=totalSignal(:,1+i*nAdcSamples*nChirps:(i+1)*nAdcSamples*nChirps)-totalSignal(:,1+(i-1)*nAdcSamples*nChirps:(i)*nAdcSamples*nChirps);
end


totalHeatmap=zeros(timeLength*frameRate-1,128,128);
for i=1:timeLength*frameRate-1
    this_frame=totalSignalDenoised(:,1+(i-1)*nAdcSamples:nAdcSamples*i);
    this_frame=this_frame.';
    this_heatmap=fft2(this_frame,nAdcSamples,128 );
    this_heatmap=fftshift(this_heatmap);
    this_heatmap=abs(this_heatmap);
    this_heatmap=this_heatmap(129:end,:);
    
    m=max(max(this_heatmap));
    [row,colomn]=find(this_heatmap==m);
    this_heatmap(1:row-10,:)=0;
    this_heatmap(row+10:end,:)=0;
    
    this_heatmap=rescale(this_heatmap);
    totalHeatmap(i,:,:)=this_heatmap;
end


end

function [vertCoordinate] = reform(rawData,nVerts,time)

RATE=120;
vertCoordinate = zeros(nVerts,time*RATE,3);
for i=1:nVerts
    vertCoordinate(i,:,1)= rawData(1:time*RATE,1+(i-1)*3);
    vertCoordinate(i,:,2)= rawData(1:time*RATE,2+(i-1)*3);
    vertCoordinate(i,:,3)= rawData(1:time*RATE,3+(i-1)*3);
end

end

function [vertCoordinateInterp] = compute_interp(vertCoordinate,time,nChirps)
length = size(vertCoordinate,2);
nVerts=size(vertCoordinate,1);
nFrames = time*20;
nSamples=120*time-1;
nInterp = 1:(nSamples/(nFrames*nChirps-1)):length;

vertCoordinateInterp=zeros(nVerts,nFrames*nChirps,3);
for i=1:nVerts
    vert_x=vertCoordinate(i,:,1);
    vert_y=vertCoordinate(i,:,2);
    vert_z=vertCoordinate(i,:,3);
    
    index = 1:length;
    
    new_x=interp1(index,vert_x,nInterp,'spline');
    new_y=interp1(index,vert_y,nInterp,'spline');
    new_z=interp1(index,vert_z,nInterp,'spline');
    vertCoordinateInterp(i,:,:)=[new_x;new_y;new_z]';
    
end
end

function [boneDistance,boneAngle] = compute_angle_distance(vertCoordinate,tx,rx,nRepeat,STICKS)

tx_x=tx(1);
tx_y=tx(2);
tx_z=tx(3);

rx_x=rx(1);
rx_y=rx(2);
rx_z=rx(3);
length = size(vertCoordinate,2);

nBones=22;

bones_cor = zeros(nBones*nRepeat,length,3);
for i=1:nBones
    num1=STICKS(i,1);
    num2=STICKS(i,2);
    for j=1:nRepeat
        bones_cor(j+(i-1)*nRepeat,:,:)=j/(nRepeat+1)*vertCoordinate(num1,:,:)+(nRepeat+1-j)/(nRepeat+1)*vertCoordinate(num2,:,:);
    end
end

boneDistance=zeros(length,nBones*nRepeat);

for i=1:nBones
    for j=1:nRepeat
        this_distance1=sqrt((bones_cor(j+(i-1)*nRepeat,:,1)-tx_x).^2+(bones_cor(j+(i-1)*nRepeat,:,2)-tx_y).^2+(bones_cor(j+(i-1)*nRepeat,:,3)-tx_z).^2);
        this_distance2=sqrt((bones_cor(j+(i-1)*nRepeat,:,1)-rx_x).^2+(bones_cor(j+(i-1)*nRepeat,:,2)-rx_y).^2+(bones_cor(j+(i-1)*nRepeat,:,3)-rx_z).^2);
        boneDistance(:,j+(i-1)*nRepeat)=this_distance1+this_distance2;
    end
    
end



boneAngle=zeros(length,nBones*nRepeat);

for i=1:nBones
    num1=STICKS(i,1);
    num2=STICKS(i,2);
    v1=vertCoordinate(num2,:,:)-vertCoordinate(num1,:,:);
    v1=squeeze(v1);
    for j=1:nRepeat
        bone_cor=bones_cor(j+(i-1)*nRepeat,:,:);
        bone_cor=squeeze(bone_cor);
        v2=[bone_cor(:,1)-tx_x,bone_cor(:,2)-tx_y,bone_cor(:,3)-tx_z];
        norm1=sum(abs(v1).^2,2).^(1/2);
        norm2=sum(abs(v2).^2,2).^(1/2);
        com=sum((v1.*v2),2);
        this_angle=acos(com./(norm1.*norm2));
        boneAngle(:,j+(i-1)*nRepeat)=this_angle';
    end
    
end

end

function [signal] = compute_signal(chirpDistance,chirpAngle,radius,length)
SLOPE_HZ_PER_SEC =124.996e12;% MHz/us
SAMPLING_RATE =  1e7; %
nAdcSamples = 256;
c = 3e8;
F0 = 77e9;
nBones=22;
ts = 1/SAMPLING_RATE;
tc = 1/SAMPLING_RATE * nAdcSamples; %time of one chirp
bw = tc*SLOPE_HZ_PER_SEC;

RCS=1/4*pi*(radius.^4).*(length.^2)./((radius.^2).*((sin(chirpAngle)).^2)+1/4*(length.^2).*((cos(chirpAngle)).^2));
RCS=sqrt(RCS);
repmat( RCS , nAdcSamples , 2 );

this_time=zeros(1,nAdcSamples);
for i = 1:nAdcSamples
    this_time(1,i) = (i-1)*ts;
end

tau=chirpDistance/c;
sample_Real=cos(2*pi*(F0*tau-bw/(2*tc)*tau.*tau+bw*tau/tc.*this_time));
sample_Real=sample_Real.*RCS;
sample_Real = sum(sample_Real,1);
sample_Image=sin(2*pi*(F0*tau-bw*tau.*tau/(2*tc)+bw*tau/tc.*this_time));
sample_Image=sample_Image.*RCS;
sample_Image = sum(sample_Image,1);

signal = complex(sample_Real,sample_Image);
end


