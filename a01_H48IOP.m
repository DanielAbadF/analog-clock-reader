
clear;
clc;
close all;

addpath("functions");

for n = 1:10

    filename = sprintf("input/%02d.png", n);

    I = imread(filename);
    restored = remove_periodic_noise(I);
    enhaced = enhace_contrast(restored);

    figure;

    subplot(1,3,1);
    imshow(I);
    title(sprintf("Original image %02d", n));

    subplot(1,3,2);
    imshow(restored);
    title(sprintf("Denoised image %02d", n));
    

   subplot(1,3,3)
   imshow(enhaced)
   title(sprintf("Enhaced image %02d", n));

end
