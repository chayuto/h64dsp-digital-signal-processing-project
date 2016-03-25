close all

[corruptedAudioArray,cleanAudio, fs] =  fn_151029_loadSample();

sectionLength = 500;
%%
audioLength = 50000;
audioChannelCount = 10;

%% global filtering

med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

inAudio = med3AvgAudio;

%%
sections = floor(audioLength/sectionLength);

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

for i = 1:sections-1
    
    %% First Part
    sectionIndexOffset = (i-1) *sectionLength;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample =inAudio(audioIndex);
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    fftAbsResult = abs(fft(fftAudioSample));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    arrayIndex = (i-1)*2 +1;
    fftArray(arrayIndex,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
    %% Second part
    
    offset = sectionLength/2;
    
    startAudioIndex = 1  + sectionIndexOffset +offset;
    endAudioIndex = sectionLength  + sectionIndexOffset +offset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample =inAudio(audioIndex);
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    
    fftAbsResult = abs(fft(fftAudioSample));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    arrayIndex = (i-1)*2 +2;
    fftArray(arrayIndex,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
end

A = sum(fftArray,1);

figure();
plot(A)

freq = [];
A(1) = 1000;
for i = 1:10
    [V,I] = min(A);
    
    A(I-15:I+15) = 1000;
    B(I) = i*100;
    freq = [freq; frequencyIndex(I)];
end

freq = sort(freq);
hold on
plot(B)

figure();
surf(fftArray);


%% 
freq = [325;freq;3999.9]; %append last freq
trackCount = length(freq);

audioTracks = zeros(audioLength,trackCount);

paddedInput = [inAudio ; zeros(2000,1)];
lowCutoff = 0.01;
for i = 1:trackCount;
    
      
      highCutoff = freq(i);
      b = fir1(2000,[lowCutoff highCutoff]/(fs/2));
      a = 1;
      
      lowCutoff = highCutoff;
      
      
      delay=1000;
      
      filtered = filter(b,a,paddedInput);
      
      audioTracks(:,i) = filtered(delay+1:delay+audioLength);
end

sumOut =sum(audioTracks,2);

for i = 1:trackCount
    
    track = audioTracks(:,i);
    [sectionIndexes,sectionsCount] = fn_151029_DynSection(track,fs);
    
    outAudio = track;
    for j = 1:sectionsCount
    
        sectionBoundary = sectionIndexes(j,:);

        % fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)
        [windowArray] = fn_151029_fftBasedFreqWindows(track,fs,sectionBoundary,4.3);

        [outAudioSection,filterDestinationIndex] = fn_151029_FIR_filter(track,fs,sectionBoundary,windowArray,2000);

        alpha = 1;
        outAudio(filterDestinationIndex) = outAudioSection * alpha + track(filterDestinationIndex) * (1- alpha) ;
 
%     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
    end
    
    audioTracksOut(:,i) = outAudio;
end

% for i = 1:trackCount
%     pause();
%     sound(audioTracksOut(:,i));
%     
% end
filteredSumOut =sum(audioTracksOut,2);
fn_151029_MSE(filteredSumOut,cleanAudio)
sound(filteredSumOut)

