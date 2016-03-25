function [windowArray] = fn_151126_fftBasedFreqWindows_Hm(inAudio,fs,...
    sectionBoundary,fftTreshold)

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
    % hamming( triang( blackman(  blackman( flattopwin( chebwin( rectwin(
    %audioSample = audioSample .* hamming(sampleLength); %best sound
    %audioSample = audioSample .* triang(sampleLength); %best MSE
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    
    fftAbsResult = abs(fft(fftAudioSample));
%     minVal = min(fftAbsResult);
%     normfftAbsResult =  fftAbsResult-minVal;
    
%     figure(2);
%     subplot(plotX,plotY,i)
%     plot(audioIndex,inAudio(audioIndex));
%     

    %% find Signal Region in FFT       
    Y = fftAbsResult(fftIndex);
    tempMaxArray = Y;
    mask = zeros(length(Y));
    for i = 1:length(Y)
     if tempMaxArray(i) > fftTreshold ;
         mask(i) = 1;
         
         %include harmonics of the frequency
         if tempMaxArray(i) > fftTreshold*6 ;             
             harmonics = 2;
             while i*harmonics < length(Y) && harmonics <6
                mask(i*harmonics-(harmonics-2):...
                    i*harmonics+(harmonics-2)) = 1;  
                harmonics = harmonics +1;
             end
%              while i*harmonics < length(Y) && harmonics <4 
%                 mask(i*harmonics) = 1;  
%                 harmonics = harmonics +1;
%              end
         end
     end
    end
    
    %% Create singal windows
    windowArray = [];
    
    startFreq = 0.0001;
    for n = 3:fftLength-2
        
        if mask(n-2) == 0 && mask(n-1) == 0 && mask(n) ==1
            startFreq = fftFrequencyIndex(n) - fftFrqGap/2 -fftFrqGap/6 ;
        end
      
        if mask(n) == 1 && mask(n+1) ==0 && mask(n+2) ==0
            stopFreq = fftFrequencyIndex(n) + fftFrqGap/2 + fftFrqGap/6;
            if stopFreq > (fs/2)
                stopFreq = (fs/2) - 1;
            end
            window = [startFreq stopFreq];
            windowArray = [ windowArray; window ];
        end
    end
    
end