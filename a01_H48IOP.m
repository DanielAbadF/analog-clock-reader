
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

    % Clock orientation and second hand
    [angleTo12, blueX, blueY] = detect_clock_orientation( ...
        blueMask, maxX, maxY);

    angleRed = detect_second_angle(redMask, maxX, maxY, radius);

    secondAngle = mod(angleRed - angleTo12, 360);
    seconds = mod(round(secondAngle / 6), 60);

    fprintf('Image %02d: seconds = %02d\n', n, seconds);

    % Hough transform of black hands
    [A, thetaValues, rhoValues, blackMask] = ...
    detect_black_hands(gray, maxX, maxY, radius);

    % Find the two strongest Hough directions near the center
    votes = sum(A(abs(rhoValues) <= 3, :), 1);

    [~, index1] = max(votes);

    % Avoid selecting the same hand twice
    angleDifference = abs(thetaValues - thetaValues(index1));
    angleDifference = min(angleDifference, 180 - angleDifference);

    votes(angleDifference <= 8) = 0;

    [~, index2] = max(votes);

    theta1 = thetaValues(index1);
    theta2 = thetaValues(index2);

    fprintf('Hough directions: %.1f and %.1f degrees\n', theta1, theta2);

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

    % 5. Hough space of the black hands
    subplot(2,3,5);

    imagesc(thetaValues, rhoValues, A);
    axis xy;
    colorbar;
    hold on;

    yline(0, 'r--', 'LineWidth', 1.5);

    hold off;

    xlabel('Theta (degrees)');
    ylabel('Rho (pixels)');
    title('Hough space of black hands');

    % 6. Detected circle and hand directions
    subplot(2,3,6);
    imshow(enhanced);
    hold on;

    theta = 0:359;

    circleX = maxX + radius * cosd(theta);
    circleY = maxY + radius * sind(theta);

    % Clock circle and center
    plot(circleX, circleY, 'g', 'LineWidth', 2);
    plot(maxX, maxY, 'r+', 'MarkerSize', 12, 'LineWidth', 2);

    % 12 o'clock marker direction
    plot([maxX, blueX], [maxY, blueY], ...
        'b-', 'LineWidth', 2);

    plot(blueX, blueY, 'bo', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'b');

    % Second hand direction
    redX = maxX + 0.8 * radius * cosd(angleRed);
    redY = maxY + 0.8 * radius * sind(angleRed);

    plot([maxX, redX], [maxY, redY], ...
        'r-', 'LineWidth', 2);

    % Hough line directions
    lineAngle1 = theta1 + 90;
    lineAngle2 = theta2 + 90;

    lengthLine = 0.75 * radius;

    % First detected line
    dx1 = lengthLine * cosd(lineAngle1);
    dy1 = lengthLine * sind(lineAngle1);

    plot([maxX-dx1, maxX+dx1], ...
        [maxY-dy1, maxY+dy1], 'c--', 'LineWidth', 2);

    % Second detected line
    dx2 = lengthLine * cosd(lineAngle2);
    dy2 = lengthLine * sind(lineAngle2);

    plot([maxX-dx2, maxX+dx2], ...
        [maxY-dy2, maxY+dy2], 'y--', 'LineWidth', 2);

    hold off;

    title(sprintf('Detected circle - R = %d, Seconds = %02d', ...
        radius, seconds));

    drawnow;

end
