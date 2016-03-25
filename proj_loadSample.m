function fn_
%%
clc
clear all
close all

%%
[corruptedAudioArray, fs] = audioread('corrupted.wav');
[cleanAudio, fs] = audioread('Clean.wav');