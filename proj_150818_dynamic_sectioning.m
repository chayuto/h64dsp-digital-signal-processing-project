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

% a = 1;
% b = [1/4 1/4 1/4 1/4];
% 
% MS = filter(b,a,MS)


mask = zeros(size(MS))
treshold = 0.0075;

for i = 1:size(MS,2)
    if MS(i) < treshold
        mask(i) = 0.03;
    end
   
end

plot(MS)
hold on 
plot(mask,'r');

% DataInv = 1.01*max(MS) - MS;





