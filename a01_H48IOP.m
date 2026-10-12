
clear;
clc;
close all;

addpath("functions");

for n = 1:10

    filename = sprintf("input/%02d.png", n);
    I = imread(filename);

    % Image preprocessing
    [restored, spectrum, peakRows, peakCols] = remove_periodic_noise(I);
    enhanced = enhace_contrast(restored);

    % Circle detection
    gray = rgb2gray(enhanced);
    edges = edge(gray, 'canny', [0.1 0.25]);

    tic;
    [maxX, maxY, radius] = detect_clock_circle(edges, gray);
    elapsedTime = toc;

    fprintf('Image %02d: center (%d, %d), radius %d, time %.4f s\n', ...
        n, maxX, maxY, radius, elapsedTime);

    % Color segmentation
    [blueMask, redMask] = detect_color_masks(enhanced);

    [angleTo12, blueX, blueY] = detect_clock_orientation(blueMask, maxX, maxY);

    maskRGB = zeros(size(enhanced));
    maskRGB(:,:,1) = redMask;
    maskRGB(:,:,3) = blueMask;

    % Visualization
    figure('WindowState', 'maximized');

    % 1. Original image
    subplot(2,3,1);
    imshow(I);
    title(sprintf('Original image %02d', n));

    % 2. Fourier spectrum and removed peaks
    subplot(2,3,2);
    imagesc(spectrum);
    axis image;
    colormap gray;
    colorbar;

    hold on;
    plot(peakCols, peakRows, 'ro', ...
        'MarkerSize', 10, 'LineWidth', 2);
    hold off;

    title('Fourier spectrum');

    % 3. Denoised and contrast-enhanced image
    subplot(2,3,3);
    imshow(enhanced);
    title('Denoised and contrast-stretched');

    % 4. Blue marker and red second hand
    subplot(2,3,4);
    imshow(maskRGB);
    title('Color masks');

    % 5. Canny edges (temporary)
    subplot(2,3,5);
    imshow(edges);
    title('Canny edges (temporary)');

    % 6. Detected clock circle
    subplot(2,3,6);
    imshow(enhanced);
    hold on;

    theta = 0:359;

    circleX = maxX + radius * cosd(theta);
    circleY = maxY + radius * sind(theta);

    plot(circleX, circleY, 'g', 'LineWidth', 2);
    plot(maxX, maxY, 'r+', 'MarkerSize', 12, 'LineWidth', 2);

    hold off;
    title(sprintf('Detected circle - R = %d', radius));

    drawnow;

end
