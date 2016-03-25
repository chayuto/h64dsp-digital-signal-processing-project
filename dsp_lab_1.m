clc
clear all
close all

sampleSize = 100
samplingFrequency =50
freq = 10
freq2 = 15 
phaseShift = 0

for i = 1:sampleSize
    s(i) = cos(2*pi*freq2*(i-1)/samplingFrequency) + cos(2*pi*freq*(i-1)/samplingFrequency + phaseShift);
    f(i) = (i-1)*samplingFrequency/sampleSize; 
    %i-1 for indexing
    
end

x=f;
figure(1)
y = abs(fft(s))
plot(x,y);
title('ampliture FFT of sine wave')

figure(2)
y = angle(fft(s))
plot(x,y);
title('phase FFT of sine wave')

figure(3)
plot(x,s);

counter =1

startingPhase = 0
endingPhase = 0.5


% for j = linspace(startingPhase,endingPhase,4)
%     phaseShift = j
%     for i = 1:sampleSize
%         s(i) = cos(2*pi*freq2*(i-1)/samplingFrequency) + cos(2*pi*freq*(i-1)/samplingFrequency  + phaseShift);
%         f(i) = (i-1)*samplingFrequency/sampleSize; 
%     end
%     x=f;
%     y = angle(fft(s))
%     figure(4)
%     subplot(4,1,counter)
%     plot(x,y);
%     counter = counter+1;
% end

freqArray = [15 20 37] 
phaseArray = [0.2 0.9 1.5] 



 

