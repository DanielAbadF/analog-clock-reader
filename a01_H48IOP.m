
clear;
clc;
close all;

addpath("functions");

for n = 1:10

    filename = sprintf("input/%02d.png", n);

    I = imread(filename);
    restored = remove_periodic_noise(I);

    figure;

    subplot(1,2,1);
    imshow(I);
    title(sprintf("Original image %02d", n));

    subplot(1,2,2);
    imshow(restored);
    title(sprintf("Denoised image %02d", n));

end
