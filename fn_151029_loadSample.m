function [corruptedAudioArray,cleanAudio, fs] =  fn_151029_loadSample()

%%
[corruptedAudioArray, fs] = audioread('corrupted.wav');
[cleanAudio, fs] = audioread('Clean.wav');