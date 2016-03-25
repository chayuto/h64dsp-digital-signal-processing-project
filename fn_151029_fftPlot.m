function [fftFreq,fftVal] =  fn_151029_fftPlot(inAudio,fs,titleStr)
sampleLength = length(inAudio);
sampleIndex = 1:sampleLength;
frequencyIndex= linspace(0,fs,sampleLength);
fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
fftLength = (sampleLength/2);
fftIndex = 1:fftLength;

figure()
fftAbs = abs(fft(inAudio));
fftFreq = frequencyIndex(fftIndex);
fftVal = fftAbs(fftIndex);
plot(fftFreq,fftVal);
title(titleStr);
