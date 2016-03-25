close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 4;
plotY = 5;

%% global filtering

med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

filterOrder = 1000;
filterDelay = filterOrder/2;
inAudio = med3AvgAudio;

tresholdFreq = 380; %500

lowCutoff = 0.2;
highCutoff= tresholdFreq ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filteredLow = filter(b,a,inAudio);

lowCutoff = tresholdFreq;
highCutoff= fs/2 - 1 ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filteredHigh = filter(b,a,inAudio);

figure(1)
subplot(3,1,1);
plot(inAudio)
subplot(3,1,2);
plot(filteredLow);
subplot(3,1,3);
plot(filteredHigh);

sampleLength = length(inAudio);
sampleIndex = 1:sampleLength;
frequencyIndex= linspace(0,fs,sampleLength);
fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
fftLength = (sampleLength/2);
fftIndex = 1:fftLength;
figure(2)
fftAbs = abs(fft(inAudio));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));
figure(3)
fftAbs = abs(fft(filteredLow));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));
figure(4)
fftAbs = abs(fft(filteredHigh));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));

sound(filteredLow);

recombine = filteredLow+filteredHigh;

my_MSE(recombine,med3AvgAudio);

%sound(filteredHigh);

%{
sound(filteredLow);
sound(filteredLow+filteredHigh);
%}


 
 
 
