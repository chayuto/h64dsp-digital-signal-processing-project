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

inAudio = med4AvgAudio;

for i = 1:sections
    
    offset = (i-1) *sectionLength;
    startAudioIndex = 1 + offset;
    endAudioIndex = sectionLength + offset;
    
    audioIndex = startAudioIndex:endAudioIndex;

    sampleIndex = 1:sectionLength;
    sampleSize = sectionLength;
    
    sectionAudio = inAudio(audioIndex);
    
    MS(i) = sum(sectionAudio.^2,1)/sampleSize;
    
end

mask = zeros(size(MS));

searchRangePlus = 20;
searchRangeMinus = 20;

for i = 1+searchRangeMinus:size(MS,2)-searchRangePlus
    MSSection = MS(i-searchRangeMinus:i+searchRangePlus);
    [minVal,Index] = min(MSSection);
    if MS(i) == minVal
        mask(i) = 1;
    end
end

figure(1)
plot(MS)
hold on 
plot(mask,'r');

%% create section Indexes

sectionIndexes(1,1) =1;
sectionCounter=1;

for i = 1:size(mask,2)-1
    if mask(i) == 0 && mask(i+1) == 1
        
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
sectionIndexes(sectionCounter,2) = audioLength;

sectionsCount = sectionCounter;

%% Sectional Processing

outAudio = inAudio;
for i = 1:sectionsCount
    
    %% FFT in each section
    sectionBoundary = sectionIndexes(i,:);
    
    startAudioIndex = sectionBoundary(1);
    endAudioIndex = sectionBoundary(2);
    
    audioIndex = startAudioIndex:endAudioIndex;
    sampleLength = endAudioIndex - startAudioIndex +1;
    sampleIndex = 1:sampleLength;
    frequencyIndex= linspace(0,fs,sampleLength);
    fftFrqGap = frequencyIndex(2) - frequencyIndex(1) ;
    fftLength = (sampleLength/2);
    fftIndex = 1:fftLength; %/2
    
    fftAbsResult = abs(fft(inAudio(audioIndex)));
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;
    
    figure(2);
    subplot(plotX,plotY,i)
    plot(audioIndex,inAudio(audioIndex));
    
    figure(3);
    subplot(plotX,plotY,i)
    plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
    
    
    %% find Peaks in FFT
    filterOrder = 2000;
    filterDelay = filterOrder/2;
    
    paddingLength = 2000;
    
    %re-adjust if outbound
    if (startAudioIndex <= paddingLength)
         paddingLength = startAudioIndex -1;
    end

    postPaddingLength = 1000;
  
    %re-adjust if outbound
    filterinputIndexEnd = endAudioIndex+ postPaddingLength;
    outbound =  filterinputIndexEnd - 50000;
   
    if outbound > 0
        postPaddingLength = postPaddingLength - outbound;
        filterinputIndexEnd = endAudioIndex+ postPaddingLength;
    else
        outbound =0;
    end
    
    filterOutputIndexStart = paddingLength + filterDelay + 1;
    
    filterInputIndex = (startAudioIndex - paddingLength):endAudioIndex+ postPaddingLength;
    filterInputLength  = length(filterInputIndex);
    
    filterOutputIndexEnd = paddingLength + sampleLength + filterDelay - outbound;
    filterOutputIndex = paddingLength + filterDelay + 1 : filterOutputIndexEnd ;
    filterOutputLength = filterOutputIndexEnd - filterOutputIndexStart +1;
    
    filterDestinationIndex = startAudioIndex:startAudioIndex+filterOutputLength-1;
       
    fftTreshold =  7; % 6.3 fft thesholding
   
    tempMaxArray = normfftAbsResult(fftIndex);
    mask = tempMaxArray > fftTreshold ;
    
    windowArray = [];
    
    startFreq = 0.01;
    for n = 2:fftLength-1
        
        if mask(n) == 0 && mask(n+1) ==1
            startFreq = frequencyIndex(n) - fftFrqGap/2;% -fftFrqGap/4 ;
        end
      
        if mask(n) == 1 && mask(n+1) ==0
            stopFreq = frequencyIndex(n) + fftFrqGap/2;% + fftFrqGap/4;
            if stopFreq > (fs/2)
                stopFreq = (fs/2) - 1;
            end
            window = [startFreq stopFreq];
            windowArray = [ windowArray; window ];
        end
    end
    
%     i
%     windowArray

    %% Filtering form window array
    
    mixedOut = zeros(filterInputLength,1);
    
    for n = 1:size(windowArray,1)
          
        lowCutoff =  windowArray(n,1) ;
        highCutoff =  windowArray(n,2);
        
%         order = 1;
%         [b,a] = butter(order, window/(fs/2), 'bandpass');
%         [b,a] = cheby1(order,3,window/(fs/2))

        b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
        a = 1;
        
        filteredSection = filter(b,a,inAudio(filterInputIndex));
        mixedOut = mixedOut + filteredSection;
        
    end
    
    alpha = 1;
    outAudio(filterDestinationIndex) = mixedOut(filterOutputIndex) * alpha + inAudio(filterDestinationIndex) * (1- alpha) ;
    
    outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
   
    figure(4);
    subplot(plotX,plotY,i)
    plot(outAudioSections(i,1:length(filterDestinationIndex)));
    
    %% FFT output
    if i~= sectionsCount
        figure(3);
        subplot(plotX,plotY,i)
        hold on 
        fftAbsResult = abs(fft(outAudio(filterDestinationIndex)));
        plot(frequencyIndex(fftIndex),fftAbsResult(fftIndex));
    end
    
    
end

my_MSE(inAudio,cleanAudio)
my_MSE(outAudio,cleanAudio)

figure(5)
plot(cleanAudio)
hold on 
plot(outAudio)
% hold on 
% plot(cleanAudio - outAudio);

sound([outAudio ; cleanAudio])

%%

