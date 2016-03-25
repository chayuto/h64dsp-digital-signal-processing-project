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
inAudio = avgAudio; %avgAudio
refAudio = med3AvgAudio;%for sectioning guideline %contain signal loss

outAudio = fn_151125_OverlapProcessing(inAudio,refAudio,fs,0,hWB);
refOutAudio = fn_151125_OverlapProcessing(refAudio,refAudio,fs,0,hWB);

delta1Audio = inAudio - outAudio;

temp1Audio = outAudio;
outAudio = fn_151125_OverlapProcessing(outAudio,refOutAudio,fs,0,hWB);
%outAudio = fn_151125_OverlapProcessing(outAudio,outAudio,fs,0,hWB);
delta2Audio = temp1Audio - outAudio;


%% cascade

tempAudio = outAudio;
outAudio = fn_151126_IIR_SP_DS_FX_4(tempAudio,tempAudio,fs,hWB);
delta2Audio = tempAudio - outAudio;

% %%
% figure();
% surf(fftArray)

deltaAudio = inAudio - outAudio;

%% Performance analysis
fn_151029_MSE(med3AvgAudio,cleanAudio)
fn_151029_MSE(tempAudio,cleanAudio)
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
