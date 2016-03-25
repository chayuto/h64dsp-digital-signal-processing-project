close all

%%
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

%% Split audio into 2 CH

inAudio = med3AvgAudio;
%proj_151026_fn_Split_2CH(inAudio,fs,tresholdFreq)
[filteredLow,filteredHigh] =  fn_151029_Split_2CH(inAudio,fs,325); %325 Hz

figure(1)
subplot(3,1,1);
plot(inAudio)
subplot(3,1,2);
plot(filteredLow);
subplot(3,1,3);
plot(filteredHigh);

%% Filter Low Frequency Section

[sectionIndexes,sectionsCount] = fn_151029_DynSection(filteredLow,fs);

outAudio = filteredLow;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    [windowArray] = fn_151030_fftBasedFreqWindows(filteredLow,fs,sectionBoundary,4);

    [outAudioSection,filterDestinationIndex] = fn_151106_FIR_filter_window(filteredLow,fs,sectionBoundary,windowArray,2000);
    
    alpha = 1;
    outAudio(filterDestinationIndex) = outAudioSection * alpha + filteredLow(filterDestinationIndex) * (1- alpha) ;
 
    %waitbar(iBlkNo/iTotalBlk,hWB,sprintf('Matching... Shift:%d, Frame:%d/%d, Blk:%d/%d ',Nshift,m,StopFrame,iBlkNo,iTotalBlk));
    waitbar(i/sectionsCount,hWB,sprintf('Filtering Low Section %d/%d...',i,sectionsCount));
    
    
    %     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
end
outAudioLow = outAudio;

%% Filter High Frequency Section
[sectionIndexes,sectionsCount] = fn_151029_DynSection(filteredHigh,fs);

outAudio = filteredHigh;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    % fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)
    [windowArray] = fn_151030_fftBasedFreqWindows(filteredHigh,fs,sectionBoundary,2.0); %3.5

    [outAudioSection,filterDestinationIndex] = fn_151106_FIR_filter_window(filteredHigh,fs,sectionBoundary,windowArray,2800);
    
    alpha = 1;
    outAudio(filterDestinationIndex) = outAudioSection * alpha + filteredHigh(filterDestinationIndex) * (1- alpha) ;
 
%     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);

    waitbar(i/sectionsCount,hWB,sprintf('Filtering High Section %d/%d...',i,sectionsCount));
end
outAudioHigh = outAudio;

% sound([outAudioLow;outAudioHigh]);

mixedOut = outAudioLow+outAudioHigh;

%% Second Pass

%% Split audio into 2 CH

inAudio = mixedOut;
%proj_151026_fn_Split_2CH(inAudio,fs,tresholdFreq)
[filteredLow,filteredHigh] =  fn_151029_Split_2CH(inAudio,fs,325); %325 Hz

figure(1)
subplot(3,1,1);
plot(inAudio)
subplot(3,1,2);
plot(filteredLow);
subplot(3,1,3);
plot(filteredHigh);

%% Filter Low Frequency Section

[sectionIndexes,sectionsCount] = fn_151029_DynSection(filteredLow,fs);

outAudio = filteredLow;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    [windowArray] = fn_151030_fftBasedFreqWindows(filteredLow,fs,sectionBoundary,4);

    [outAudioSection,filterDestinationIndex] = fn_151106_FIR_filter_window(filteredLow,fs,sectionBoundary,windowArray,2000);
    
    alpha = 1;
    outAudio(filterDestinationIndex) = outAudioSection * alpha + filteredLow(filterDestinationIndex) * (1- alpha) ;
 
    %waitbar(iBlkNo/iTotalBlk,hWB,sprintf('Matching... Shift:%d, Frame:%d/%d, Blk:%d/%d ',Nshift,m,StopFrame,iBlkNo,iTotalBlk));
    waitbar(i/sectionsCount,hWB,sprintf('Filtering Low Section %d/%d...',i,sectionsCount));
    
    
    %     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);
end
outAudioLow = outAudio;

%% Filter High Frequency Section
[sectionIndexes,sectionsCount] = fn_151029_DynSection(filteredHigh,fs);

outAudio = filteredHigh;
for i = 1:sectionsCount
    
    sectionBoundary = sectionIndexes(i,:);
    
    % fn_151029_fftBasedFreqWindows(inAudio,fs,sectionBoundary,fftTreshold)
    [windowArray] = fn_151030_fftBasedFreqWindows(filteredHigh,fs,sectionBoundary,3.0); %3.5

    [outAudioSection,filterDestinationIndex] = fn_151106_FIR_filter_window(filteredHigh,fs,sectionBoundary,windowArray,2800);
    
    alpha = 1;
    outAudio(filterDestinationIndex) = outAudioSection * alpha + filteredHigh(filterDestinationIndex) * (1- alpha) ;
 
%     outAudioSections(i,1:length(filterDestinationIndex)) = outAudio(filterDestinationIndex);

    waitbar(i/sectionsCount,hWB,sprintf('Filtering High Section %d/%d...',i,sectionsCount));
end
outAudioHigh = outAudio;

% sound([outAudioLow;outAudioHigh]);

mixedOut = outAudioLow+outAudioHigh;

%%

% sound(mixedOut);
sound([mixedOut;cleanAudio]);
%% Performance analysis
fn_151029_MSE(mixedOut,cleanAudio)
 
figure(5)
plot(cleanAudio)
hold on 
plot(mixedOut)
hold on 
plot(cleanAudio - mixedOut);

%% Error analysis
[refLow,refHigh] =  fn_151029_Split_2CH(cleanAudio,fs,325); %325 Hz
errorAudio = cleanAudio - mixedOut ;
errorLow = refLow - outAudioLow;
errorHigh = refHigh - outAudioHigh;

figure()
subplot(3,1,1);
plot(errorLow)
subplot(3,1,2);
plot(errorHigh);
subplot(3,1,3);
plot(errorAudio);
% sound([errorLow;errorHigh]);

%% FFT noise
fn_151029_fftPlot(errorAudio,fs,'errorAudio');
fn_151029_fftPlot(cleanAudio,fs,'cleanAudio');

fn_151029_fftPlot(mixedOut,fs,'mixedOut');
fn_151029_fftPlot(med3AvgAudio,fs,'med3AvgAudio');

%% Spectrogram

proj_151027_fn_3Dspectrogram(cleanAudio,fs,500);

%% Clean up

close(hWB);
