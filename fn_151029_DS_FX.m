function [outAudio] = fn_151029_DS_FX(inAudio,fs,fftTreshold)

audioLength = length(inAudio);

%% Dynamic Sectioning
[sectionIndexes,sectionsCount] = fn_151029_DynSection(inAudio,fs);

%% Sectional Processing
outAudio = inAudio;
for i = 1:sectionsCount
    
    %% FFT in each section
    sectionBoundary = sectionIndexes(i,:);
    
    [windowArray] = fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold);

    [outAudioSection,filterDestinationIndex] = fn_151029_FIR_filter(inAudio,fs,sectionBoundary,windowArray,2000);
    
    alpha = 1;
    outAudio(filterDestinationIndex) = outAudioSection * alpha + inAudio(filterDestinationIndex) * (1- alpha) ;
    
%     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
end


end