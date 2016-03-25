audioLength = 50000;
audioChannelCount = 10;

startAudioIndex = 1000;
audioSampleLength = 20000;
audioIndex = startAudioIndex:startAudioIndex+audioSampleLength-1;

sampleIndex = 1:audioSampleLength;
sampleSize = audioSampleLength;

%sound(cleanAudio,fs)
%sound(corruptedAudioArray(:,1),fs)

%%
figure(1) 
subplot(2,1,1)
plot(sampleIndex,cleanAudio(audioIndex));
title('Clean');


subplot(2,1,2)
plot(sampleIndex,corruptedAudioArray(audioIndex,1));
title('Corrupted CH1');
