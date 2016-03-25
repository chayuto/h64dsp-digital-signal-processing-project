function [windowArray] = fn_151126_freqWinFromFFT(fftResult,fftFrequencyIndex,fs,fftTreshold)     
   
    fftFrqGap = fftFrequencyIndex(2) - fftFrequencyIndex(1) ;
    fftLength = length(fftResult);
%     tempMaxArray = normfftAbsResult(fftIndex);
    tempMaxArray = fftResult;
    mask = zeros(length(fftResult));
    for i = 1:length(fftResult)
     if tempMaxArray(i) > fftTreshold ;
         mask(i) = 1;
         if i >2
             mask(i-1) = 1;
         end
         if i < length(fftResult)
             mask(i+1) = 1;
         end
         %include harmonics of the frequency
         if tempMaxArray(i) > fftTreshold*4 ;             
             harmonics = 2;
             while i*harmonics < length(fftResult) && harmonics <10
                mask(i*harmonics-(harmonics-1):i*harmonics+(harmonics-1)) = 1;  
                harmonics = harmonics +1;
             end
         end
     end
    end
    
    %% Create singal windows
    windowArray = [];
    
    startFreq = 0.001;
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