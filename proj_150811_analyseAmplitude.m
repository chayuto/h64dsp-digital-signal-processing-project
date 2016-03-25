close all
%%
audioLength = 50000;
audioChannelCount = 10;

%%
%global filtering

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

plot(MS)
threshold1  = 0.017;
factor1 = 0.76;
factor2 = 0.65;
mask = MS > threshold1;

outAudio = zeros(size(med4AvgAudio));

for i = 1:sections
    
    offset = (i-1) *sectionLength;
    startAudioIndex = 1 + offset;
    endAudioIndex = sectionLength + offset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    if i>1 && i ~= sections
        if mask(i) == 0 && mask(i-1) == 0 && mask(i+1) == 0
            outAudio(audioIndex) = med4AvgAudio(audioIndex) * factor2;
        elseif  mask(i) == 0
            outAudio(audioIndex) = med4AvgAudio(audioIndex) * factor1;
        else
            outAudio(audioIndex) = med4AvgAudio(audioIndex);
        end
    else
        if mask(i) == 1
            outAudio(audioIndex) = med4AvgAudio(audioIndex);
        else
            outAudio(audioIndex) = med4AvgAudio(audioIndex) * factor1;
        end
    end
end

%%
%performace measure

%plot(outAudio)
%plot(mask)
sound(outAudio)
A = my_MSE(med4AvgAudio,cleanAudio)
B = my_MSE(outAudio,cleanAudio)
A - B

%plot(outAudio-cleanAudio)

