audioLength = 50000;
audioChannelCount = 10;

startAudioIndex = 800;
audioSampleLength = 40000;
audioIndex = startAudioIndex:startAudioIndex+audioSampleLength-1;

sampleIndex = 1:audioSampleLength;
sampleSize = audioSampleLength;

%sound(cleanAudio,fs)
%sound(corruptedAudioArray(:,1),fs)

avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
medAudio = medfilt1(corruptedAudioArray,4,[],2);
medAvgAudio = sum(medAudio,2)/audioChannelCount;
med2Audio = medfilt1(avgAudio,3,[],1); %avg then med

%%
figure(1) 
subplot(2,1,1)
plot(audioIndex,cleanAudio(audioIndex));
title('Clean');

subplot(2,1,2)
plot(audioIndex,medAvgAudio(audioIndex));
title('med -> avg');
