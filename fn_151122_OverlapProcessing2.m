function [outAudio] = fn_151122_OverlapProcessing2(inAudio,refAudio,fs,offset,hWB)

audioLength = length(inAudio);

%%
sectionLength =1000;

sections = floor(audioLength/sectionLength) * 4 -3;
sectionOffset = sectionLength/4;

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

outAudio = inAudio;

for i = 1:sections-1
    sectionIndexOffset = (i-1) *sectionOffset + offset;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample = refAudio(audioIndex);
    %hamming
    fftAudioSample = fftAudioSample .* tukeywin(fftSampleLength,0.15);
    fftAbsResult = abs(fft(fftAudioSample));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
    %% FFT find freqwindows
    sectionBoundary = [startAudioIndex,endAudioIndex];
    [windowArray] = fn_151111_freqWinFromFFT(fftArray(i,:),frequencyIndex,fs,2.3);
    
    [outAudioSection,filterDestinationIndex] = fn_151113_FIR_filter_window_2(inAudio,fs,sectionBoundary,windowArray,2000); %500

     %triang hamming
    outputWindow = hamming(length(outAudioSection));
    outputWindowCompliment = 1 - outputWindow;
    
    outAudio(filterDestinationIndex) = outAudioSection .*outputWindow + inAudio(filterDestinationIndex) .* outputWindowCompliment ;
 
    waitbar(i/sections,hWB,sprintf('Overlap Processing %d/%d...',i,sections));
end

end