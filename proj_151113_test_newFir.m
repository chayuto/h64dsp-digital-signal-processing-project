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

avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;

%% 
inAudio = avgAudio;
outAudio = fn_151113_SP_DS_FX_4(avgAudio,avgAudio,fs,hWB);