function  fn_151111_Overlap3Dspectrogram(inAudio,fs,sectionLength)
audioLength = length(inAudio);
%%
sections = floor(audioLength/sectionLength) * 4 -4;
sectionOffset = sectionLength/4;

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

for i = 1:sections
    
    sectionIndexOffset = (i-1) *sectionOffset;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample = inAudio(audioIndex);
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    fftAbsResult = abs(fft(fftAudioSample));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
end

figure();
surf(fftArray);
