%%
close all

hWB = waitbar(0,'Working...');

%%
[corruptedAudioArray,cleanAudio, fs] =  fn_151029_loadSample();

%%
audioLength = 50000;
audioChannelCount = 10;

%% global filtering
waitbar(0,hWB,'Global Filtering');
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;
avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;


%% 
inAudio = med3AvgAudio; %avgAudio


outAudio = fn_151126_SP_DS_FX_4(inAudio,inAudio,fs,hWB);
delta2Audio = inAudio - outAudio;

% %%
% figure();
% surf(fftArray)

deltaAudio = inAudio - outAudio;

%% Performance analysis
fn_151029_MSE(med3AvgAudio,cleanAudio)
fn_151029_MSE(outAudio,cleanAudio)
 
figure(5)
plot(cleanAudio)
hold on 

plot(outAudio)
hold on 
plot(cleanAudio - outAudio);

%%
errorAudio = cleanAudio - outAudio;

%% FFT noise
fn_151029_fftPlot(errorAudio,fs,'errorAudio');
fn_151029_fftPlot(cleanAudio,fs,'cleanAudio');
fn_151029_fftPlot(outAudio,fs,'outAudio');

%% Spectrogram
proj_151027_fn_3Dspectrogram(errorAudio,fs,500);

%% Clean up

close(hWB);
