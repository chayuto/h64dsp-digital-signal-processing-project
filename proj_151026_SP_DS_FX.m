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

filterOrder = 1000;
filterDelay = filterOrder/2;
inAudio =  med3AvgAudio; %cleanAudio - mixedOut

inAudio = [inAudio; zeros(filterDelay,1)]; %padding for filter

tresholdFreq = 325; %500

lowCutoff = 0.2;
highCutoff= tresholdFreq ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filterOut = filter(b,a,inAudio);
filteredLow = filterOut(filterDelay+1:audioLength+filterDelay);

lowCutoff = tresholdFreq;
highCutoff= fs/2 - 1 ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;
filterOut = filter(b,a,inAudio);
filteredHigh  = filterOut(filterDelay+1:audioLength+filterDelay);

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


inAudio = filteredLow;

%%
sectionLength = 50;
sections = 1000;


for i = 1:sections
    
    offset = (i-1) *sectionLength;
    audioIndexStart = 1 + offset;
    audioIndexEnd = sectionLength + offset;
    
    audioIndex = audioIndexStart:audioIndexEnd;

    sampleIndex = 1:sectionLength;
    sampleSize = sectionLength;
    
    sectionAudio = inAudio(audioIndex);
    
    MS(i) = sum(sectionAudio.^2,1)/sampleSize;
    
end

mask = zeros(size(MS));

searchRangePlus = 23;
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
        
        if tempSectionIndex\2 == 0 
            tempSectionIndex = tempSectionIndex-1;
        end
        
        sectionIndexes(sectionCounter,2)  = tempSectionIndex;
        sectionCounter = sectionCounter+1;
        sectionIndexes(sectionCounter,1)  = tempSectionIndex +1;
    end
    
end
sectionIndexes(sectionCounter,2) = audioLength;

sectionsCount = sectionCounter;

%% Sectional Processing

outputBoundary = [];

outAudio = inAudio;
for i = 1:sectionsCount
    
    %% FFT in each section
    
    
    sectionBoundary = sectionIndexes(i,:);
    
    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);
    sampleIndex = 1:sampleLength;
    
    %get fft samples
    fftExtendSample = 100;
    fftSampleIndexStart = audioIndexStart - 100;
    if fftSampleIndexStart <1
        fftSampleIndexStart = 1;
    end
    
    fftSampleIndexEnd = audioIndexEnd - 100;
    if fftSampleIndexEnd > audioLength
        fftSampleIndexEnd = audioLength;
    end
    
    fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd;
    fftSampleLength = length(fftSampleIndex);
    
    %re-adjust if fft sample is odd
    if fftSampleLength\2 ~= 0 
            fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd-1;
            fftSampleLength = length(fftSampleIndex);
    end
    
    fftFrequencyIndex= linspace(0,fs,fftSampleLength);
    fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
    fftLength = (fftSampleLength/2);
    fftIndex = 1:fftLength; %/2
    
    fftAudioSample = inAudio(fftSampleIndex);
    
    %TODO: windowing.
    % hamming( triang( blackman(  blackman( flattopwin( chebwin(
    %audioSample = audioSample .* hamming(sampleLength); %best sound
    %audioSample = audioSample .* triang(sampleLength); %best MSE
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    
    fftAbsResult = abs(fft(fftAudioSample));
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;
    
    figure(2);
    subplot(plotX,plotY,i)
    plot(audioIndex,inAudio(audioIndex));
    
    figure(3);
    subplot(plotX,plotY,i)
    plot(fftFrequencyIndex(fftIndex),fftAbsResult(fftIndex));
    
    
    %% find Peaks in FFT       
    fftTreshold =  3.2; % 5.7 6.3 fft thesholding
   
    tempMaxArray = normfftAbsResult(fftIndex);
    mask = tempMaxArray > fftTreshold ;
    
    windowArray = [];
    
    startFreq = 0.01;
    for n = 2:fftLength-1
        
        if mask(n) == 0 && mask(n+1) ==1
            startFreq = fftFrequencyIndex(n) - fftFrqGap/2 -fftFrqGap/6 ;
        end
      
        if mask(n) == 1 && mask(n+1) ==0
            stopFreq = fftFrequencyIndex(n) + fftFrqGap/2 + fftFrqGap/6;
            if stopFreq > (fs/2)
                stopFreq = (fs/2) - 1;
            end
            window = [startFreq stopFreq];
            windowArray = [ windowArray; window ];
        end
    end
    
%     i
%     windowArray

    %% Filter padding and indexting 
    
    filterOrder = 2000;
    filterDelay = filterOrder/2;
    
    paddingLength = 2000;
    
    %re-adjust if outbound
    if (audioIndexStart <= paddingLength)
         paddingLength = audioIndexStart -1;
    end

    postPaddingLength = 2000;
  
    %re-adjust if outbound
    filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    outbound =  filterinputIndexEnd - 50000;
   
    if outbound > 0
        postPaddingLength = postPaddingLength - outbound;
        filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    else
        outbound =0;
    end
    
    
    filterInputIndexStart = audioIndexStart - paddingLength;
    filterInputIndexEnd = audioIndexEnd+ postPaddingLength;
    filterInputIndex = filterInputIndexStart:filterInputIndexEnd;
    
    filterInputLength  = length(filterInputIndex);
    
    filterOutputIndexStart = paddingLength + filterDelay + 1;
    filterOutputIndexEnd = paddingLength + sampleLength + filterDelay - outbound;
    filterOutputIndex = filterOutputIndexStart : filterOutputIndexEnd ;
    filterOutputLength = length(filterOutputIndex);
    
    filterDestinationIndex = audioIndexStart:audioIndexStart+filterOutputLength-1;
    
    outputBoundary= [ outputBoundary; [audioIndexStart,audioIndexStart+filterOutputLength-1]];

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
        
        fftSampleLength = length(filterDestinationIndex);
        fftFrequencyIndex= linspace(0,fs,fftSampleLength);
        fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
        fftLength = (fftSampleLength/2);
        fftIndex = 1:fftLength; %/2
        fftAbsResult = abs(fft(outAudio(filterDestinationIndex)));
        plot(fftFrequencyIndex(fftIndex),fftAbsResult(fftIndex));
    end
    
    
end

outAudioLow = outAudio;

%%

inAudio = filteredHigh;

%%
sectionLength = 50;
sections = 1000;


for i = 1:sections
    
    offset = (i-1) *sectionLength;
    audioIndexStart = 1 + offset;
    audioIndexEnd = sectionLength + offset;
    
    audioIndex = audioIndexStart:audioIndexEnd;

    sampleIndex = 1:sectionLength;
    sampleSize = sectionLength;
    
    sectionAudio = inAudio(audioIndex);
    
    MS(i) = sum(sectionAudio.^2,1)/sampleSize;
    
end

mask = zeros(size(MS));

searchRangePlus = 23;
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
        
        if tempSectionIndex\2 == 0 
            tempSectionIndex = tempSectionIndex-1;
        end
        
        sectionIndexes(sectionCounter,2)  = tempSectionIndex;
        sectionCounter = sectionCounter+1;
        sectionIndexes(sectionCounter,1)  = tempSectionIndex +1;
    end
    
end
sectionIndexes(sectionCounter,2) = audioLength;

sectionsCount = sectionCounter;

%% Sectional Processing

outputBoundary = [];

outAudio = inAudio;
for i = 1:sectionsCount
    
    %% FFT in each section
    
    
    sectionBoundary = sectionIndexes(i,:);
    
    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);
    sampleIndex = 1:sampleLength;
    
    %get fft samples
    fftExtendSample = 100;
    fftSampleIndexStart = audioIndexStart - 100;
    if fftSampleIndexStart <1
        fftSampleIndexStart = 1;
    end
    
    fftSampleIndexEnd = audioIndexEnd - 100;
    if fftSampleIndexEnd > audioLength
        fftSampleIndexEnd = audioLength;
    end
    
    fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd;
    fftSampleLength = length(fftSampleIndex);
    
    %re-adjust if fft sample is odd
    if fftSampleLength\2 ~= 0 
            fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd-1;
            fftSampleLength = length(fftSampleIndex);
    end
    
    fftFrequencyIndex= linspace(0,fs,fftSampleLength);
    fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
    fftLength = (fftSampleLength/2);
    fftIndex = 1:fftLength; %/2
    
    fftAudioSample = inAudio(fftSampleIndex);
    
    %TODO: windowing.
    % hamming( triang( blackman(  blackman( flattopwin( chebwin(
    %audioSample = audioSample .* hamming(sampleLength); %best sound
    %audioSample = audioSample .* triang(sampleLength); %best MSE
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    
    fftAbsResult = abs(fft(fftAudioSample));
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;
    
    figure(2);
    subplot(plotX,plotY,i)
    plot(audioIndex,inAudio(audioIndex));
    
    figure(3);
    subplot(plotX,plotY,i)
    plot(fftFrequencyIndex(fftIndex),fftAbsResult(fftIndex));
    
    
    %% find Peaks in FFT       
    fftTreshold =  5.7; % 5.7 6.3 fft thesholding
   
    tempMaxArray = normfftAbsResult(fftIndex);
    mask = tempMaxArray > fftTreshold ;
    
    windowArray = [];
    
    startFreq = 0.01;
    for n = 2:fftLength-1
        
        if mask(n) == 0 && mask(n+1) ==1
            startFreq = fftFrequencyIndex(n) - fftFrqGap/2 -fftFrqGap/6 ;
        end
      
        if mask(n) == 1 && mask(n+1) ==0
            stopFreq = fftFrequencyIndex(n) + fftFrqGap/2 + fftFrqGap/6;
            if stopFreq > (fs/2)
                stopFreq = (fs/2) - 1;
            end
            window = [startFreq stopFreq];
            windowArray = [ windowArray; window ];
        end
    end
    
%     i
%     windowArray

    %% Filter padding and indexting 
    
    filterOrder = 2000;
    filterDelay = filterOrder/2;
    
    paddingLength = 2000;
    
    %re-adjust if outbound
    if (audioIndexStart <= paddingLength)
         paddingLength = audioIndexStart -1;
    end

    postPaddingLength = 2000;
  
    %re-adjust if outbound
    filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    outbound =  filterinputIndexEnd - 50000;
   
    if outbound > 0
        postPaddingLength = postPaddingLength - outbound;
        filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    else
        outbound =0;
    end
    
    
    filterInputIndexStart = audioIndexStart - paddingLength;
    filterInputIndexEnd = audioIndexEnd+ postPaddingLength;
    filterInputIndex = filterInputIndexStart:filterInputIndexEnd;
    
    filterInputLength  = length(filterInputIndex);
    
    filterOutputIndexStart = paddingLength + filterDelay + 1;
    filterOutputIndexEnd = paddingLength + sampleLength + filterDelay - outbound;
    filterOutputIndex = filterOutputIndexStart : filterOutputIndexEnd ;
    filterOutputLength = length(filterOutputIndex);
    
    filterDestinationIndex = audioIndexStart:audioIndexStart+filterOutputLength-1;
    
    outputBoundary= [ outputBoundary; [audioIndexStart,audioIndexStart+filterOutputLength-1]];

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
        
        fftSampleLength = length(filterDestinationIndex);
        fftFrequencyIndex= linspace(0,fs,fftSampleLength);
        fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
        fftLength = (fftSampleLength/2);
        fftIndex = 1:fftLength; %/2
        fftAbsResult = abs(fft(outAudio(filterDestinationIndex)));
        plot(fftFrequencyIndex(fftIndex),fftAbsResult(fftIndex));
    end
    
    
end

outAudioHigh = outAudio;

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

errorAudio = cleanAudio - inAudio ;

figure(6);
plot(errorAudio);

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
 
 
