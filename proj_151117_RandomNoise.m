%%
close all


%%
[corruptedAudioArray,cleanAudio, fs] =  fn_151029_loadSample();

%%
audioLength = 50000;
audioChannelCount = 10;

%% global filtering
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;
avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;


noise = med3AvgAudio-cleanAudio;
max(noise)
sigma = std(noise);
figure(1)
subplot(1,2,1)
histogram(noise,100)
title('Noise Histrogram')

R = normrnd(0,sigma,[1,50000]);
subplot(1,2,2)
histogram(R,100)
title('Norm Dist')



