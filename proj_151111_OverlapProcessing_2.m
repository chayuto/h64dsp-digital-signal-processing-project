%%
close all
clear all
hWB = waitbar(0,'Working...');

%%
[corruptedAudioArray,cleanAudio, fs] =  fn_151029_loadSample();

%%
audioLength = 50000;
audioChannelCount = 10;

%% global filtering
waitbar(0,hWB,'Global Filtering');
med3Audio = medfilt1(corruptedAudioArray,3,[],2);
%med5Audio = medfilt1(corruptedAudioArray,5,[],2);
med3AvgAudio= sum(med3Audio,2)/audioChannelCount;
%med5AvgAudio = sum(med5Audio,2)/audioChannelCount;

%% 
inAudio = med3AvgAudio;

audioLength = length(inAudio);

%%

sectionLength = 1000;
overlap = 4;
range = sectionLength/overlap; %250
focusSection = [sectionLength/2-range/2+1,sectionLength/2+range/2];

sections = floor(audioLength/sectionLength) * overlap -(overlap-1);
sectionOffset = sectionLength/overlap;

fftArray = zeros(sections,sectionLength/2);

sampleIndex = 1:sectionLength;
sampleSize = sectionLength;
frequencyIndex= linspace(0,fs,sampleSize);
fftIndex = 1:(size(sampleIndex,2)/2); %/2

outAudio = inAudio;
for i = 1:sections
    
    sectionIndexOffset = (i-1) *sectionOffset;
    startAudioIndex = 1  + sectionIndexOffset;
    endAudioIndex = sectionLength  + sectionIndexOffset;
    
    focusWindow = focusSection+sectionIndexOffset;
    
    audioIndex = startAudioIndex:endAudioIndex;
    
    fftSampleLength = length(audioIndex);
    
    fftAudioSample = inAudio(audioIndex);
    fftAudioSample = fftAudioSample .* hamming(fftSampleLength);
    fftAbsResult = abs(fft(fftAudioSample));
    
    minVal = min(fftAbsResult);
    normfftAbsResult =  fftAbsResult-minVal;

    %fftAbsResult = abs(fft(cleanAudio(audioIndex)));
    fftArray(i,:) = permute(normfftAbsResult(fftIndex),[2,1]);
    
    %% FFT find freqwindows
%     sectionBoundary = [startAudioIndex,endAudioIndex];
    [windowArray] = fn_151111_freqWinFromFFT(fftArray(i,:),frequencyIndex,fs,5);
    
    [outAudioSection,filterDestinationIndex] = fn_151106_FIR_filter_window(inAudio,fs,focusWindow,windowArray,500); %500

     %triang hamming rectwin
    outputWindow = tukeywin(length(outAudioSection),0.25);
    outputWindowCompliment = 1 - outputWindow;
    
    outAudio(filterDestinationIndex) = outAudioSection .*outputWindow + inAudio(filterDestinationIndex) .* outputWindowCompliment ;
 
    waitbar(i/sections,hWB,sprintf('Overlap Processing %d/%d...',i,sections));
end

delta1Audio = inAudio - outAudio;

%% cascade

tempAudio = outAudio;
outAudio = fn_151111_SP_DS_FX_4(tempAudio,fs,hWB);
delta2Audio = tempAudio - outAudio;

% % compare
% 
% refFilterAudio = fn_151111_SP_DS_FX_4(inAudio,fs,hWB);


%%
figure();
surf(fftArray)

deltaAudio = inAudio - outAudio;

%% Performance analysis
fn_151029_MSE(med3AvgAudio,cleanAudio)
fn_151029_MSE(tempAudio,cleanAudio)
fn_151029_MSE(outAudio,cleanAudio)
 
figure(5)
plot(cleanAudio)
hold on 
plot(outAudio)
hold on 
plot(cleanAudio - outAudio);

%%
errorAudio = cleanAudio - outAudio;


%% Clean up

close(hWB);
