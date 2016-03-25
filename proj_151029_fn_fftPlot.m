function [fftFreq,fftVal] =  proj_151029_fn_fftPlot(inAudio,fs)

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
