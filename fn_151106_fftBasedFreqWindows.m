function [windowArray] =  fn_151106_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)

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
    
    X = fftFrequencyIndex(fftIndex);
    Y = fftAbsResult(fftIndex);
    
    T = zeros(length(X),1);
    avgFactor = 2;
    for i = avgFactor+1:length(X)-avgFactor
        T(i) = mean(Y(i-avgFactor:i+avgFactor));
    end
%     figure();
%     plot(X,Y);
%     hold on
%     plot(X,T);
    
    title('FFT')
    
    
    %% find Signal Region in FFT       
   
%     tempMaxArray = normfftAbsResult(fftIndex);
    tempMaxArray = T;
    mask = zeros(length(T));
    for i = 1:length(T)
     if tempMaxArray(i) > fftTreshold ;
         mask(i) = 1;
         if i>1
             mask(i+1) = 1;
         end
         
         if i <length(T)
            mask(i-1) = 1;
         end
         
         %include harmonics of the frequency
         if tempMaxArray(i) > fftTreshold*6 ;             
             harmonics = 2;
             while i*harmonics < length(T) && harmonics <4 
                mask(i*harmonics) = 1;  
                harmonics = harmonics +1;
             end
         end
     end
    end
    
    %% Create singal windows
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