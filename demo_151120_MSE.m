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
for i = 1:10
    corrupt = fn_151029_MSE(corruptedAudioArray(:,i),cleanAudio)
    MSE(i) = corrupt;
end
avg = fn_151029_MSE(avgAudio,cleanAudio)

med = fn_151029_MSE(med3Audio(:,1),cleanAudio)
medAvg = fn_151029_MSE(med3AvgAudio,cleanAudio)