function [ret_heatmaps] = fft_2d(file_name,time_length)

%%% This function is used to generate 2D heatmaps
%%% from raw FMCW data

n_adc_samples = 256;  % number of adc samples in one chirp
n_chirps = 128; % number of chirps in one frame
frame_rate=20; % number of frames per second
cnt_chirp=time_length*frame_rate*n_chirps;

% load and reform raw data
raw_data=read1443Data(file_name);
tx1_data=zeros(4,time_length*frame_rate*n_chirps*n_adc_samples);
tx2_data=zeros(4,time_length*frame_rate*n_chirps*n_adc_samples);
for i=1:cnt_chirp
    tx1_data(:,1+(i-1)*n_adc_samples:n_adc_samples*i)=raw_data(:,1+(i-1)*n_adc_samples*2:n_adc_samples+(i-1)*n_adc_samples*2);
    tx2_data(:,1+(i-1)*n_adc_samples:n_adc_samples*i)=raw_data(:,n_adc_samples+1+(i-1)*n_adc_samples*2:n_adc_samples*2+(i-1)*n_adc_samples*2);
end
raw_data=[tx2_data;tx1_data];
clear Tx1_data
clear Tx2_data

% static removal
denoised_data=zeros(8,(time_length*frame_rate-1)*n_chirps*n_adc_samples);
for i=1:time_length*frame_rate-1
    denoised_data(:,1+(i-1)*n_adc_samples*n_chirps:n_adc_samples*n_chirps*i)=raw_data(:,1+i*n_adc_samples*n_chirps:(i+1)*n_adc_samples*n_chirps)-raw_data(:,1+(i-1)*n_adc_samples*n_chirps:(i)*n_adc_samples*n_chirps);
end

% generate heatmaps
ret_heatmaps=zeros(time_length*frame_rate-1,n_adc_samples/2,n_chirps);
for i=1:time_length*frame_rate-1
    chirp=denoised_data(:,1+(i-1)*n_adc_samples*n_chirps:n_adc_samples+(i-1)*n_adc_samples*n_chirps);
    chirp=chirp.';
    heatmap=abs(fftshift(fft2(chirp,n_adc_samples,n_chirps)));
    heatmap=heatmap(129:end,:);
    heatmap(end-20:end,:)=0;
    m=max(max(heatmap));
    [row,colomn]=find(heatmap==m);
    heatmap(1:row-10,:)=0;
    heatmap(row+10:end,:)=0;
    heatmap=rescale(heatmap);
    heatmap(heatmap<0.05)=0;
    heatmap=rescale(heatmap);
    ret_heatmaps(i,:,:)=heatmap;
end
end

