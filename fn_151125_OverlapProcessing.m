function [outAudio] = fn_151125_OverlapProcessing(inAudio,...
    refAudio,fs,globalOffset,hWB)

audioLength = length(inAudio);

%%
sectionLength =1000;

sections = floor(audioLength/sectionLength) * 4 -3;
sectionOffset = sectionLength/4 ;

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

outAudio = inAudio;
for i = 1:sections
    
    sectionIndexOffset = (i-1) *sectionOffset ;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample = refAudio(audioIndex);
    %hamming
    %tukeywin(fftSampleLength,0.25);
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    fftAbsResult = abs(fft(fftAudioSample));
    
    %minVal = min(fftAbsResult);
    %normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(fftAbsResult(fftIndex),[2,1]);
    
    %% FFT find freqwindows
    sectionBoundary = [startAudioIndex,endAudioIndex];
    [windowArray] = fn_151125_freqWinFromFFT(fftArray(i,:),frequencyIndex,fs,2.2);
    
    [outAudioSection,filterDestinationIndex] = fn_151125_FIR_filter_window(inAudio,fs,sectionBoundary,windowArray,2000); %500

     %triang hamming
     %tukeywin(length(outAudioSection),0.15)
     % hamming(length(outAudioSection));
     %tukeywin(length(outAudioSection),0.75);
    outputWindow =[zeros(50,1);hamming(length(outAudioSection)-100);zeros(50,1)];
    outputWindowCompliment = 1 - outputWindow;
    
    outAudio(filterDestinationIndex) = outAudioSection .*outputWindow +  outAudio(filterDestinationIndex) .* outputWindowCompliment ;
 
    waitbar(i/sections,hWB,sprintf('Overlap Processing %d/%d...',i,sections));
end

end