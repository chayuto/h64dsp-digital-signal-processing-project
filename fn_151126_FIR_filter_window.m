function [outAudioSection,filterDestinationIndex]...
    = fn_151126_FIR_filter_window(inAudio,fs,sectionBoundary...
    ,windowArray,order)

    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);

    %% Filter padding and indexting 
    
    filterOrder = order;
    filterDelay = filterOrder/2;
    
    
    paddingLength = 2000;
    %re-adjust if outbound (prepad)
    if (audioIndexStart <= paddingLength)
         paddingLength = audioIndexStart -1;
    end
    postPaddingLength = 2000;
    filterInputIndexEnd = audioIndexEnd+ postPaddingLength;
    outbound =  filterInputIndexEnd - 50000;
   
    %re-adjust if outbound
    if outbound > 0
        %pad with zero, if outbound
    else
        outbound =0;
    end
    filterInputIndexStart = audioIndexStart - paddingLength;
    filterInputIndexEnd = filterInputIndexEnd - outbound;
    filterInputIndex = filterInputIndexStart:filterInputIndexEnd;  
    filterInputLength  = length(filterInputIndex);
    
    filterInputAudioSection = inAudio(filterInputIndex);
    paddedFilterInputAudioSection = [filterInputAudioSection ; zeros(outbound,1)];
    
    filterOutputIndexStart = paddingLength + filterDelay + 1;
    filterOutputIndexEnd = paddingLength + sampleLength + filterDelay;
    filterOutputIndex = filterOutputIndexStart : filterOutputIndexEnd ;
    filterOutputLength = length(filterOutputIndex);
    
    filterDestinationIndex = audioIndex;
    
   
    %% Filtering form window array
    mixedOut = zeros(filterInputLength + outbound,1);
    
    for n = 1:size(windowArray,1)
          
        lowCutoff =  windowArray(n,1) ;
        highCutoff =  windowArray(n,2);
        
        if (lowCutoff < 0.1) %if less than 0.1 Hz, change to low pass
            b = fir1(filterOrder,highCutoff/(fs/2),'low');
            a = 1;
        else
            b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
            a = 1;
        end

        filteredSection = filter(b,a, paddedFilterInputAudioSection);
        mixedOut = mixedOut + filteredSection;
        
    end
    
    outAudioSection = mixedOut(filterOutputIndex);
    
end


