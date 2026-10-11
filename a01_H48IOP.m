
clear;
clc;
close all;

addpath("functions");

for n = 1:10

    filename = sprintf("input/%02d.png", n);

    I = imread(filename);
    [restored, spectrum, peakRows, peakCols] = remove_periodic_noise(I);
    enhanced = enhace_contrast(restored);
    gray = rgb2gray(enhanced);

    edges = edge(gray, 'canny', [0.1 0.25]);

    tic;
    [maxX, maxY, radius] = detect_clock_circle(edges);
    toc;

    fprintf('Circle center: (%d, %d), radius: %d\n',  maxX, maxY, radius);

    figure; 

    subplot(1,5,1);
    imshow(I);
    title(sprintf("Original image %02d", n));

    subplot(1,5,2);
    imagesc(spectrum);
    axis image;
    colormap gray;
    colorbar;

    hold on;
    plot(peakCols, peakRows, 'ro', ...
        'MarkerSize', 10, 'LineWidth', 2);
    hold off;

    title('Fourier spectrum and removed peaks');
    
    subplot(1,5,3)
    imshow(enhanced)
    title(sprintf("Enhaced image %02d", n));
end
