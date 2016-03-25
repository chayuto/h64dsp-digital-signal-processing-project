close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 4;
plotY = 5;

%% global filtering
avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
med4Audio = medfilt1(corruptedAudioArray,4,[],2);
med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio = sum(med3Audio,2)/audioChannelCount;
med4AvgAudio = sum(med4Audio,2)/audioChannelCount;
med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

avgMedAudio = medfilt1(avgAudio,3,[],1); %avg then med

avgAudioMSE = my_MSE(avgAudio,cleanAudio)
median3MSE = my_MSE(med3AvgAudio,cleanAudio)
median4MSE = my_MSE(med4AvgAudio,cleanAudio)
median4MSE = my_MSE(med5AvgAudio,cleanAudio)
% avgMedianMSE = my_MSE(avgMedAudio,cleanAudio)

%% Stack raw

stackCorruptedAudioArray = [corruptedAudioArray,corruptedAudioArray];
stackChannelCount = 20;

Stackmed3Audio = medfilt1(stackCorruptedAudioArray,3,[],2);
Stackmed4Audio = medfilt1(stackCorruptedAudioArray,4,[],2);
Stackmed5Audio = medfilt1(stackCorruptedAudioArray,4,[],2);
Stackmed3AvgAudio = sum(Stackmed3Audio,2)/stackChannelCount;
Stackmed4AvgAudio = sum(Stackmed4Audio,2)/stackChannelCount;
Stackmed5AvgAudio = sum(Stackmed5Audio(:,6:15),2)/10;

Stackmedian3MSE = my_MSE(Stackmed3AvgAudio,cleanAudio)
Stackmedian4MSE = my_MSE(Stackmed4AvgAudio,cleanAudio)
Stackmedian5MSE = my_MSE(Stackmed5AvgAudio,cleanAudio)

