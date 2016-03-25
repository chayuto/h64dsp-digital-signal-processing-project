function [sectionIndexes,sectionsCount] = fn_151029_DynSection(inAudio,fs)

audioLength = length(inAudio);

%%
sectionLength = 50;
sections = 1000;

MS = zeros(1,sections);
for i = 1:sections
    
    offset = (i-1) *sectionLength;
    audioIndexStart = 1 + offset;
    audioIndexEnd = sectionLength + offset;
    
    audioIndex = audioIndexStart:audioIndexEnd;
    
    sectionAudio = inAudio(audioIndex);
    
    MS(i) = sum(sectionAudio.^2,1)/sectionLength;
    
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


% figure(1)
% plot(MS)
% hold on 
% plot(mask,'r');

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
