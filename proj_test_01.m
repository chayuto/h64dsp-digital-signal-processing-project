audioLength = 50000;
audioChannelCount = 10;

startAudioIndex = 5;
audioSampleLength = 1000;
audioIndex = startAudioIndex:startAudioIndex+audioSampleLength-1;

sampleIndex = 1:audioSampleLength;
sampleSize = audioSampleLength;

frequencyIndex= linspace(0,fs,sampleSize);

fftIndex = 1:(size(sampleIndex,2)/2); %/2

%sound(cleanAudio,fs)
%sound(corruptedAudioArray(:,1),fs)

%%
%{
figure(1) 
subplot(2,1,1)
plot(sampleIndex,cleanAudio(sampleIndex));

subplot(2,1,2)
plot(sampleIndex,corruptedAudioArray(sampleIndex,1));
%}

%%
avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
medAudio = medfilt1(corruptedAudioArray,3,[],1);
medAvgAudio = sum(medAudio,2)/audioChannelCount;

med2Audio = medfilt1(avgAudio,3,[],1); %avg then med


%%

%fftAbsResult = abs(fft(cleanAudio(sampleIndex)));
%fftAbsResult = abs(fft(corruptedAudioArray(sampleIndex,1)));
figure(1) 
subplot(2,2,1)
fftAbsResult = abs(fft(cleanAudio(sampleIndex)));
plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
title('Clean');

subplot(2,2,2)
fftAbsResult = abs(fft(corruptedAudioArray(sampleIndex,1)));
plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
title('Corrupted');

subplot(2,2,3)
fftAbsResult = abs(fft(avgAudio(sampleIndex)));
plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
title('10 sample average');

subplot(2,2,4)
fftAbsResult = abs(fft(medAvgAudio(sampleIndex)));
plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
title('Median filter > 10 sample avg');

%sound(avg2Audio,fs)
%sound(corruptedAudioArray(:,1))
%sound(cleanAudio,fs)

%%
%performance measurement

mse1 = my_MSE(corruptedAudioArray(:,1),cleanAudio)
mse2 = my_MSE(avgAudio,cleanAudio)
mse3 = my_MSE(medAudio(:,1),cleanAudio)
mse4 = my_MSE(medAvgAudio,cleanAudio)

%%
figure(2) 
subplot(4,1,1)
plot(audioIndex,corruptedAudioArray(audioIndex,1)-cleanAudio(audioIndex))
title('Corrupted');
subplot(4,1,2)
plot(audioIndex,avgAudio(audioIndex)-cleanAudio(audioIndex))
title('10 sample average');
subplot(4,1,3)
plot(audioIndex,medAudio(audioIndex,1)-cleanAudio(audioIndex))
title('Median filter');
subplot(4,1,4)
plot(audioIndex,medAvgAudio(audioIndex)-cleanAudio(audioIndex))
title('Median filter > 10 sample avg');




