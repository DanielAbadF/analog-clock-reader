
clear;
clc;
close all;

addpath("functions");

for n = 1:10

    filename = sprintf("input/%02d.png", n);

    I = imread(filename);
    [restored, spectrum, peakRows, peakRows] = remove_periodic_noise(I);
    enhanced = enhace_contrast(restored);
    gray = rgb2gray(enhanced);

    edges = edge(gray, 'canny', [0.1 0.25]);

    figure; 

    subplot(1,4,1);
    imshow(I);
    title(sprintf("Original image %02d", n));

    subplot(2,3,2);
    imagesc(spectrum);
    axis image;
    colormap gray;
    colorbar;

    hold on;
    plot(peakCols, peakRows, 'ro', ...
        'MarkerSize', 10, 'LineWidth', 2);
    hold off;

    title('Fourier spectrum and removed peaks');
    
    subplot(1,4,3)
    imshow(enhanced)
    title(sprintf("Enhaced image %02d", n));

    subplot(1,4,4)
    imshow(edges)
    title(sprintf("Edges of image %02d", n));


end
