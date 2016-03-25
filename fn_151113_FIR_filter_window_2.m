function [outAudioSection,filterDestinationIndex]...
    = fn_151113_FIR_filter_window_2(inAudio,fs,sectionBoundary...
    ,windowArray,order)

    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);

    %% Filter padding and indexting 
    
    filterOrder = order;
    filterDelay = filterOrder/2;
    
    
    paddingLength = 4000;
    %re-adjust if outbound (prepad)
    if (audioIndexStart <= paddingLength)
         paddingLength = audioIndexStart -1;
    end
    postPaddingLength = 4000;
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
        
%         order = 1;
%         [b,a] = butter(order, window/(fs/2), 'bandpass');
%         [b,a] = cheby1(order,3,window/(fs/2))

        b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
        a = 1;
%         filterOrder
%         filterDelay = grpdelay(b,a) 
        
        %[b,a] = butter(order, [lowCutoff highCutoff]/(fs/2), 'bandpass');
        
        
        %zero post pad (anyway)

        filteredSection = filter(b,a, paddedFilterInputAudioSection);
        mixedOut = mixedOut + filteredSection;
        
    end
    
    outAudioSection = mixedOut(filterOutputIndex);
    
end


