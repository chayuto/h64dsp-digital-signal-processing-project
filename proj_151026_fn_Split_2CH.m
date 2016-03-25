function [filteredLow,filteredHigh] = proj_151026_fn_Split_2CH(inAudio,fs,tresholdFreq)

audioLength = length(inAudio);
filterOrder = 1000;
filterDelay = filterOrder/2;

inAudio = [inAudio; zeros(filterDelay,1)]; %padding for filter

% tresholdFreq = 325; %500

lowCutoff = 0.001;
highCutoff= tresholdFreq ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;

filterOut = filter(b,a,inAudio);
filteredLow = filterOut(filterDelay+1:audioLength+filterDelay);

lowCutoff = tresholdFreq;
highCutoff= fs/2 - 1 ;
b = fir1(filterOrder,[lowCutoff highCutoff]/(fs/2));
a = 1;
filterOut = filter(b,a,inAudio);
filteredHigh  = filterOut(filterDelay+1:audioLength+filterDelay);

end