function [outAudioSection,filterDestinationIndex] = fn_151029_FIR_filter(inAudio,fs,sectionBoundary,windowArray,order)

    audioIndexStart = sectionBoundary(1);
    audioIndexEnd = sectionBoundary(2);
    audioIndex = audioIndexStart:audioIndexEnd;
    sampleLength = length(audioIndex);

    %% Filter padding and indexting 
    
    filterOrder = order;
    filterDelay = filterOrder/2;
    
    paddingLength = 2000;
    
    %re-adjust if outbound
    if (audioIndexStart <= paddingLength)
         paddingLength = audioIndexStart -1;
    end

    postPaddingLength = 2000;
  
    %re-adjust if outbound
    filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    outbound =  filterinputIndexEnd - 50000;
   
    if outbound > 0
        postPaddingLength = postPaddingLength - outbound;
        filterinputIndexEnd = audioIndexEnd+ postPaddingLength;
    else
        outbound =0;
    end
    
    
    filterInputIndexStart = audioIndexStart - paddingLength;
    filterInputIndexEnd = audioIndexEnd+ postPaddingLength;
    filterInputIndex = filterInputIndexStart:filterInputIndexEnd;
    
    filterInputLength  = length(filterInputIndex);
    
    filterOutputIndexStart = paddingLength + filterDelay + 1;
    filterOutputIndexEnd = paddingLength + sampleLength + filterDelay - outbound;
    filterOutputIndex = filterOutputIndexStart : filterOutputIndexEnd ;
    filterOutputLength = length(filterOutputIndex);
    
    filterDestinationIndex = audioIndexStart:audioIndexStart+filterOutputLength-1;
    
   
    %% Filtering form window array
    mixedOut = zeros(filterInputLength,1);
    
    for n = 1:size(windowArray,1)
          
        lowCutoff =  windowArray(n,1) ;
        highCutoff =  windowArray(n,2);
        
%         order = 1;
%         [b,a] = butter(order, window/(fs/2), 'bandpass');
%         [b,a] = cheby1(order,3,window/(fs/2))

        b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
        a = 1;
        
        filteredSection = filter(b,a,inAudio(filterInputIndex));
        mixedOut = mixedOut + filteredSection;
        
    end
    
    outAudioSection = mixedOut(filterOutputIndex);
    
end


