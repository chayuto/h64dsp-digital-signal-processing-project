close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 4;
plotY = 5;

%% global filtering

med4Audio = medfilt1(corruptedAudioArray,4,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med4AvgAudio= sum(med4Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

filterOrder = 1000;
filterDelay = filterOrder/2;
inAudio = med4AvgAudio;

tresholdFreq = 325; %380 500

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

%% second split
filterOrder = 1000;
filterDelay = filterOrder/2;
inAudio = filteredHigh;

tresholdFreq = 840;%920 380 500

lowCutoff = 0.2;
highCutoff= tresholdFreq ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filteredMid= filter(b,a,inAudio);

lowCutoff = tresholdFreq;
highCutoff= fs/2 - 1 ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filteredHigh = filter(b,a,inAudio);

figure(1)
subplot(3,1,1);
plot(inAudio)
subplot(3,1,2);
plot(filteredMid);
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
fftAbs = abs(fft(filteredMid));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));
figure(4)
fftAbs = abs(fft(filteredHigh));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));

sound([filteredMid;filteredHigh]);

%{
sound(filteredLow);
sound(filteredLow+filteredHigh);
%}


 
 
 
