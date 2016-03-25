close all
%%
audioLength = 50000;
audioChannelCount = 10;

plotX = 4;
plotY = 5;

%% global filtering

avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
med4Audio = medfilt1(corruptedAudioArray,4,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio = sum(med3Audio,2)/audioChannelCount;
med4AvgAudio = sum(med4Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

avgMedAudio = medfilt1(avgAudio,3,[],1); %avg then med

%%

startAudioIndex = 1;
audioSampleLength = 50000;

audioIndex = startAudioIndex:startAudioIndex+audioSampleLength-1;

sampleIndex = 1:audioSampleLength;
sampleSize = audioSampleLength;

%plot(sampleIndex,med2Audio(sampleIndex))

%%
sectionLength = 50;
sections = 1000;

for i = 1:sections
    
    offset = (i-1) *sectionLength;
    startAudioIndex = 1 + offset;
    endAudioIndex = sectionLength + offset;
    
    audioIndex = startAudioIndex:endAudioIndex;

    sampleIndex = 1:sectionLength;
    sampleSize = sectionLength;
    
    sectionAudio = med4AvgAudio(audioIndex);
    
    MS(i) = sum(sectionAudio.^2,1)/sampleSize;
    
end

mask = zeros(size(MS));
treshold = 0.015;

spacer = 50;

for i = spacer:size(MS,2)-spacer
    
    section = MS(i:i+spacer);
    [minVal,Index] = min(section);
    
    if sum(mask(i-spacer+1+Index:i+Index)) == 0
        if minVal  < treshold 
            mask(i+Index-1) = 1;
        end
    end
   
end

figure(1)
plot(MS)
hold on 
plot(mask,'r');

%% create section Indexes
sectionsCount = sum(mask) +1;

sectionIndexes = zeros(sectionsCount,2);
sectionIndexes(1,1) =1;
sectionCounter=1;

for i = 1:size(mask,2)
    if mask(i) > 0 
        
        %make sure each section has even sample
        tempSectionIndex = sectionLength * (i-1);
        if tempSectionIndex\2 ~= 0 
            tempSectionIndex = tempSectionIndex+1;
        end
        
        sectionIndexes(sectionCounter,2)  = tempSectionIndex;
        sectionCounter = sectionCounter+1;
        sectionIndexes(sectionCounter,1)  = tempSectionIndex +1;
    end
    
end
sectionIndexes(sectionsCount,2) = audioLength;

%% FFT in each section

for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    audioIndex = sectionBoundary(1):sectionBoundary(2);
    sampleLength = sectionBoundary(2) - sectionBoundary(1) +1;
    sampleIndex = 1:sampleLength;
    frequencyIndex= linspace(0,fs,sampleLength);
    fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
    fftLength = (sampleLength/2);
    fftIndex = 1:fftLength; %/2
    
    fftAbsResult = abs(fft(med4AvgAudio(audioIndex)));
    
    figure(2);
    subplot(plotX,plotY,i)
    plot(audioIndex,med4AvgAudio(audioIndex));
    
    figure(3);
    subplot(plotX,plotY,i)
    plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
end













