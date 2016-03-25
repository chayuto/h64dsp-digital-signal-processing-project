# README #



### Intro ###

Our aim in this project is to clean up a corrupted audio files and obtain an output audio signal that is as close to the uncorrupted clean audio as possible. We are given with 10 channels of corrupted audio. Each contains uncorrelated noise with the same underlying signal. We need to utilize different signal filtering technique and determine how well it clean up the noise. Additionally, we are given clean audio as reference. We can use this as a benchmark on how well our filter perform qualitatively and quantitatively but we cannot use it in signal processing

### ~ ###

We have achieved the method in filtering the signal combining different techniques to get the closest output signal to the clean signal. In this project, we learnt to analyze and visualize the signal components (3D spectrogram), identify type of noises and plan for filtering strategy. Additionally, we have applied different techniques in choosing cut-off frequencies for our filter. We also explored the effect of using different windowing methods and how it affects the output. With the idea of nondestructive filtering, this allows us to cascade multiple filters after another. We did introduce some high frequency artifact when tried to process the signal section by section and finally managed to remove the artifact by processing individual channel and apply filters afterwards. We have found that output closest to the clean signal achieved (lowest MSE), may not sound the best for the listener. Lastly we noted the limitations of our filtering methods. 