function  fn_151027_3Dspectrogram(inAudio,fs,sectionLength)

audioLength = length(inAudio);

%%
sections = floor(audioLength/sectionLength);

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

for i = 1:sections
    
    sectionIndexOffset = (i-1) *sectionLength;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftAbsResult = abs(fft(inAudio(audioIndex)));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
end

figure();
surf(fftArray);
