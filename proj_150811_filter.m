audioLength = 50000;
audioChannelCount = 10;

startAudioIndex = 1;
audioSampleLength = 50000;
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
%global filtering

avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
med4Audio = medfilt1(corruptedAudioArray,4,[],2);
med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med6Audio = medfilt1(corruptedAudioArray,6,[],2);
med3AvgAudio = sum(med3Audio,2)/audioChannelCount;
med4AvgAudio = sum(med4Audio,2)/audioChannelCount;
med5AvgAudio = sum(med5Audio,2)/audioChannelCount;
med6AvgAudio = sum(med6Audio,2)/audioChannelCount;

med4Med2Audio = medfilt1(med4Audio,3,[],1);
med4Med2AvgAudio = sum(med4Med2Audio,2)/audioChannelCount;


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
fftAbsResult = abs(fft(med3AvgAudio(sampleIndex)));
plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
title('Median filter > 10 sample avg');

%sound(avg2Audio,fs)
%sound(corruptedAudioArray(:,1))
%sound(cleanAudio,fs)

%%
%performance measurement

mse1 = my_MSE(corruptedAudioArray(:,1),cleanAudio)
mse2 = my_MSE(avgAudio,cleanAudio)
mse3 = my_MSE(med3Audio(:,1),cleanAudio)
mse4 = my_MSE(med3AvgAudio,cleanAudio)
mse5 = my_MSE(med4AvgAudio,cleanAudio)
mse6 = my_MSE(med5AvgAudio,cleanAudio)
mse7 = my_MSE(med6AvgAudio,cleanAudio)
mse8 = my_MSE(med4Med2AvgAudio,cleanAudio)

%%
figure(2) 
subplot(4,1,1)
plot(audioIndex,corruptedAudioArray(audioIndex,1)-cleanAudio(audioIndex))
title('Corrupted');
subplot(4,1,2)
plot(audioIndex,avgAudio(audioIndex)-cleanAudio(audioIndex))
title('10 sample average');
subplot(4,1,3)
plot(audioIndex,med3Audio(audioIndex,1)-cleanAudio(audioIndex))
title('Median filter');
subplot(4,1,4)
plot(audioIndex,med3AvgAudio(audioIndex)-cleanAudio(audioIndex))
title('Median filter > 10 sample avg');




