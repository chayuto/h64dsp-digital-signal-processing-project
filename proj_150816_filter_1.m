close all
%%

audioLength = 50000;
audioChannelCount = 10;


%%
%global filtering

avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;
medAudio = medfilt1(corruptedAudioArray,4,[],2);
medAvgAudio = sum(medAudio,2)/audioChannelCount;
med2Audio = medfilt1(avgAudio,3,[],1); %avg then med
    
%%
%divide audio into small sections.

initialOffset = 1050;
sectionLength = 690; %even only
sections = 64;
plotX = 8;
plotY = 8;

fftArray = zeros(sections,sectionLength/2);
fftArray2 = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleLength = sectionLength;
frequencyIndex= linspace(0,fs,sampleLength);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

outAudio = medAvgAudio;

for i = 1:sections
    
    sectionIndexOffset = (i-1) *sectionLength;
    startAudioIndex = 1 +initialOffset + sectionIndexOffset;
    endAudioIndex = sectionLength +initialOffset + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    figure(1);
    subplot(plotX,plotY,i)
    plot(audioIndex,medAvgAudio(audioIndex));

    %%
    
    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    %fftAbsResult = abs(fft(corruptedAudioArray(audioIndex,1)));
    %fftAbsResult = abs(fft(avgAudio(audioIndex)));
    fftAbsResult = abs(fft(medAvgAudio(audioIndex)));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
    %     fftAbsResult = abs(fft(corruptedAudioArray(sampleIndex,1)));
    %     fftAbsResult = abs(fft(avgAudio(sampleIndex)));
    %     fftAbsResult = abs(fft(medAvgAudio(sampleIndex)));

%%
    paddingLength = 1000;
    postPading = 1000;
    filterInputIndex = (startAudioIndex - paddingLength):endAudioIndex + postPading;
    filterInputLength  = paddingLength +postPading + sampleLength;
    filterOutputIndex = paddingLength + 1:paddingLength+sampleLength;
    
    mixedOut = zeros(sampleLength,1);
    
    tempMaxArray = normfftAbsResult(fftIndex);
    windowArray = [];
    rowCount = 0;
    
    
    %filter testing
    while (rowCount < 35 && sum(tempMaxArray) ~= 0)
 
        [M,I] = max(tempMaxArray);
        maxFreq = frequencyIndex(I);
        tempMaxArray(I) = 0 ;
        exitFlag = 0;
        
        for n = 1:rowCount
            if maxFreq >  windowArray(n,1) && maxFreq <  windowArray(n,2)
                %if all within exsiting windows
                exitFlag = 1;
            end
        end
        
        if maxFreq <= 0
            exitFlag = 1;
        end
        
        if exitFlag ~= 1;
        
            freq1 = maxFreq;
            windowSize = maxFreq * 0.035;
            window = [freq1-windowSize freq1+windowSize];
            windowArray = [ windowArray; window ]
            rowCount = rowCount +1;
            
            if freq1+windowSize < (fs/2)
                order = 1;
                %[b,a] = butter(order, window/(fs/2), 'bandpass');
                %[b,a] = cheby1(order,3,window/(fs/2))
                
                b = fir1(1200,window/(fs/2));
                a = 1;
                
                filteredSection = filter(b,a,medAvgAudio(filterInputIndex));
                mixedOut = mixedOut + filteredSection(filterOutputIndex);
            end
        end
    end
    
    outAudio(audioIndex) = mixedOut;
    
    figure(2);
    subplot(plotX,plotY,i)
    plot(audioIndex,outAudio(audioIndex));
    
    %%
    
    fftAbsResult = abs(fft(mixedOut));
    fftArray2(i,:) = permute(fftAbsResult(fftIndex),[2,1]);
    
end

figure(3)
for i = 1:sections
    subplot(plotX,plotY,i)
    normfftAbsResult = fftArray(i,:);
    plot(frequencyIndex(fftIndex),normfftAbsResult);
    hold on
    normfftAbsResult = fftArray2(i,:);
    plot(frequencyIndex(fftIndex),normfftAbsResult,'r');
end

figure(4)
%bar3(fftArray);
surf(fftArray);

figure(5)
normfftAbsResult = fftArray(8,:);
plot(frequencyIndex(fftIndex),normfftAbsResult);
 
my_MSE(outAudio,cleanAudio)

figure(6)
plot(outAudio)
sound(outAudio)

%{

%%
%fftArray = fftArray(fftArray > 2 )
%mesh(fftArray);

%%

%performance measurement

mse1 = my_MSE(corruptedAudioArray(:,1),cleanAudio)
mse2 = my_MSE(avgAudio,cleanAudio)
mse3 = my_MSE(medAudio(:,1),cleanAudio)
mse4 = my_MSE(medAvgAudio,cleanAudio)


figure(2) 
subplot(4,1,1)
plot(audioIndex,corruptedAudioArray(:,1)-cleanAudio)
title('Corrupted');
subplot(4,1,2)
plot(audioIndex,avgAudio-cleanAudio)
title('10 sample average');
subplot(4,1,3)
plot(audioIndex,medAudio(:,1)-cleanAudio)
title('Median filter');
subplot(4,1,4)
plot(audioIndex,medAvgAudio-cleanAudio)
title('Median filter > 10 sample avg');
%}




