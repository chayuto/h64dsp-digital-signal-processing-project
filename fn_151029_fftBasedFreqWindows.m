function [windowArray] =  fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)

    audioLength = length(inAudio);
    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);
    
    %get fft samples
    fftExtendSample = 100;
    fftSampleIndexStart = audioIndexStart - 100;
    if fftSampleIndexStart <1
        fftSampleIndexStart = 1;
    end
    
    fftSampleIndexEnd = audioIndexEnd - 100;
    if fftSampleIndexEnd > audioLength
        fftSampleIndexEnd = audioLength;
    end
    
    fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd;
    fftSampleLength = length(fftSampleIndex);
    
    %re-adjust if fft sample is odd
    if fftSampleLength\2 ~= 0 
            fftSampleIndex = fftSampleIndexStart:fftSampleIndexEnd-1;
            fftSampleLength = length(fftSampleIndex);
    end
    
    fftFrequencyIndex= linspace(0,fs,fftSampleLength);
    fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
    fftLength = (fftSampleLength/2);
    fftIndex = 1:fftLength; %/2
    
    fftAudioSample = inAudio(fftSampleIndex);
    
    %TODO: windowing.
    % hamming( triang( blackman(  blackman( flattopwin( chebwin(
    %audioSample = audioSample .* hamming(sampleLength); %best sound
    %audioSample = audioSample .* triang(sampleLength); %best MSE
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    
    fftAbsResult = abs(fft(fftAudioSample));
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;
    
%     figure(2);
%     subplot(plotX,plotY,i)
%     plot(audioIndex,inAudio(audioIndex));
%     
%     figure();
%     plot(fftFrequencyIndex(fftIndex),fftAbsResult(fftIndex));
%     title('FFT')
    
    
    %% find Peaks in FFT       
   
    tempMaxArray = normfftAbsResult(fftIndex);
    mask = tempMaxArray > fftTreshold ;
    
    windowArray = [];
    
    startFreq = 0.01;
    for n = 2:fftLength-1
        
        if mask(n) == 0 && mask(n+1) ==1
            startFreq = fftFrequencyIndex(n) - fftFrqGap/2 -fftFrqGap/6 ;
        end
      
        if mask(n) == 1 && mask(n+1) ==0
            stopFreq = fftFrequencyIndex(n) + fftFrqGap/2 + fftFrqGap/6;
            if stopFreq > (fs/2)
                stopFreq = (fs/2) - 1;
            end
            window = [startFreq stopFreq];
            windowArray = [ windowArray; window ];
        end
    end
    
end