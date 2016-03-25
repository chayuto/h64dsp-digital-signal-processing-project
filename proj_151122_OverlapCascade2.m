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
inAudio = avgAudio;
% refAudio = med3AvgAudio;%for sectioning guideline %contain signal loss

% refOutAudio = fn_151122_OverlapProcessing2(refAudio,refAudio,fs,0,hWB);
outAudio =fn_151122_OverlapProcessing2(inAudio,inAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,0,hWB);
fn_151029_MSE(outAudio,cleanAudio)
%%
% outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,25,hWB);
% fn_151029_MSE(outAudio,cleanAudio)
% outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,75,hWB);
% fn_151029_MSE(outAudio,cleanAudio)
% outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,125,hWB);
% fn_151029_MSE(outAudio,cleanAudio)
% outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,175,hWB);
% fn_151029_MSE(outAudio,cleanAudio)
% outAudio =fn_151122_OverlapProcessing2(outAudio,outAudio,fs,225,hWB);
% fn_151029_MSE(outAudio,cleanAudio)

delta1Audio = inAudio - outAudio;
error1Audio = cleanAudio - outAudio;

%% cascade

tempAudio = outAudio;
outAudio = fn_151113_SP_DS_FX_4(tempAudio,tempAudio,fs,hWB);
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


%% Clean up

close(hWB);
