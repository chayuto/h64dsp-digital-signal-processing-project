close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 4;
plotY = 5;

%% global filtering

med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med4AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

inAudio = med3Audio(:,3);
% inAudio = med4AvgAudio;

errorAudio = cleanAudio - inAudio ;

figure();
plot(errorAudio);
%% FFT noise

sampleLength = length(errorAudio);
sampleIndex = 1:sampleLength;
frequencyIndex= linspace(0,fs,sampleLength);
fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
fftLength = (sampleLength/2);
fftIndex = 1:fftLength;
figure(2)
fftAbs = abs(fft(errorAudio));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));

sound(errorAudio)
