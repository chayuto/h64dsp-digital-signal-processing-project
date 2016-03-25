close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 5;
plotY = 5;

%% global filtering

med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

%% Split audio into 2 CH

inAudio = med3AvgAudio;
%proj_151026_fn_Split_2CH(inAudio,fs,tresholdFreq)
[filteredLow,filteredHigh] =  proj_151026_fn_Split_2CH(inAudio,fs,325); %325 Hz

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


%% Filter with Dynamic Section and FFT extension

%proj_151026_fn_DS_FX(inAudio,fs,fftTreshold)
outAudioLow = proj_151026_fn_DS_FX(filteredLow,fs,3.3);
outAudioHigh = proj_151026_fn_DS_FX(filteredHigh,fs,4.7);

% sound([outAudioLow;outAudioHigh]);

mixedOut = outAudioLow+outAudioHigh;

sound(mixedOut);

my_MSE(mixedOut,cleanAudio)
 
figure(5)
plot(cleanAudio)
hold on 
plot(mixedOut)
hold on 
plot(cleanAudio - mixedOut);

%% Error analysis

errorAudio = cleanAudio - mixedOut ;

figure(6);
plot(errorAudio);
%sound(errorAudio);

%% FFT noise
sampleLength = length(errorAudio);
sampleIndex = 1:sampleLength;
frequencyIndex= linspace(0,fs,sampleLength);
fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
fftLength = (sampleLength/2);
fftIndex = 1:fftLength;
figure(7)
fftAbs = abs(fft(errorAudio));
plot(frequencyIndex(fftIndex),fftAbs(fftIndex));

 
%% Spectrogram

proj_151027_fn_3Dspectrogram(cleanAudio,fs,500);
