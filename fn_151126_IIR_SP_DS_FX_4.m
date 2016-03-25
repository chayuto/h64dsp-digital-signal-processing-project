function [mixedOut] =  fn_151126_IIR_SP_DS_FX_4(inAudio,refAudio,fs,hWB)

%proj_151026_fn_Split_2CH(inAudio,fs,tresholdFreq)
[filteredLow,filteredHigh] =  fn_151029_Split_2CH(inAudio,fs,325); %325 Hz
[refFilteredLow,refFilteredHigh] =  fn_151029_Split_2CH(refAudio,fs,325); %325 Hz

%% Filter Low Frequency Section

[sectionIndexes,sectionsCount] = fn_151029_DynSection(refFilteredLow,fs);

outAudio = filteredLow;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    [windowArray] = fn_151125_fftBasedFreqWindows_Hm(refFilteredLow,fs,sectionBoundary,3.5);

    [outAudioSection,filterDestinationIndex] = fn_151126_IIR_filter_window(filteredLow,fs,sectionBoundary,windowArray,2000);
    
    outputWindow = rectwin(length(outAudioSection));
    outputWindowCompliment = 1 - outputWindow;
    outAudio(filterDestinationIndex) = outAudioSection .*outputWindow + filteredHigh(filterDestinationIndex) .* outputWindowCompliment ;
    
    previousSectionLastIndex = sectionBoundary(2);
    
    %waitbar(iBlkNo/iTotalBlk,hWB,sprintf('Matching... Shift:%d, Frame:%d/%d, Blk:%d/%d ',Nshift,m,StopFrame,iBlkNo,iTotalBlk));
    waitbar(i/sectionsCount,hWB,sprintf('Filtering Low Section %d/%d...',i,sectionsCount));
    
    
    %     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
end
outAudioLow = outAudio;

%% Filter High Frequency Section
[sectionIndexes,sectionsCount] = fn_151029_DynSection(refFilteredHigh,fs);

outAudio = filteredHigh;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    % fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)
    [windowArray] = fn_151111_fftBasedFreqWindows_Hm(refFilteredHigh,fs,sectionBoundary,3.5);%2.0  %3.5

    [outAudioSection,filterDestinationIndex] = fn_151113_FIR_filter_window_2(filteredHigh,fs,sectionBoundary,windowArray,2000);
    
    %rectwin
    outputWindow = rectwin(length(outAudioSection));
   %outputWindow = tukeywin(length(outAudioSection),0.25);
    outputWindowCompliment = 1 - outputWindow;
    outAudio(filterDestinationIndex) = outAudioSection .*outputWindow + filteredHigh(filterDestinationIndex) .* outputWindowCompliment ;
 
%     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);

    waitbar(i/sectionsCount,hWB,sprintf('Filtering High Section %d/%d...',i,sectionsCount));
end
outAudioHigh = outAudio;

% sound([outAudioLow;outAudioHigh]);

mixedOut = outAudioLow+outAudioHigh;


