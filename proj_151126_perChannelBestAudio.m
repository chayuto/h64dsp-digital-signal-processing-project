%%
close all
hWB = waitbar(0,'Working...');
hWB2 = waitbar(0,'Working...');
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
avgAudio = sum(corruptedAudioArray,2)/audioChannelCount;

%% 

refAudio = med3AvgAudio;%for sectioning guideline %contain signal loss
refOutAudio = fn_151126_OverlapProcessing(refAudio,refAudio,fs,0,hWB);
refOutAudio = fn_151126_OverlapProcessing(refOutAudio,refOutAudio,fs,0,hWB);

filteredAudioArray = zeros(audioLength,audioChannelCount);
for i = 1:audioChannelCount
    waitbar(i/audioChannelCount,hWB2,sprintf('Processing Channel %d/%d...',i,audioChannelCount));

    inAudio = corruptedAudioArray(:,i);
    outAudio = fn_151126_OverlapProcessing(inAudio,refOutAudio,fs,0,hWB);
    outAudio = fn_151126_OverlapProcessing(outAudio,outAudio,fs,0,hWB);
    delta1Audio = inAudio - outAudio;

    %% cascade
    tempAudio = outAudio;
    outAudio = fn_151126_SP_DS_FX_4(tempAudio,refOutAudio,fs,hWB);
    delta2Audio = tempAudio - outAudio;
    
    deltaAudio = inAudio - outAudio;
    
    filteredAudioArray(:,i) = outAudio;
end

outMed3Audio = medfilt1(filteredAudioArray,3,[],2);
outAudio = sum(outMed3Audio,2)/audioChannelCount;

% %%
% figure();
% surf(fftArray)

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
proj_151027_fn_3Dspectrogram(errorAudio,fs,500);

%% FFT
fn_151029_fftPlot(errorAudio,fs,'errorAudio');
fn_151029_fftPlot(cleanAudio,fs,'cleanAudio');
fn_151029_fftPlot(outAudio,fs,'outAudio');


%% Clean up

close(hWB);
close(hWB2);
