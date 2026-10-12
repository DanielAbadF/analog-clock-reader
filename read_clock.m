
function [time, consistent] = read_clock(I)
%READ_CLOCK Read an analog clock and check hand consistency.

    % Image preprocessing
    [restored, spectrum, peakRows, peakCols] = remove_periodic_noise(I);
    enhanced = enhace_contrast(restored);

    % Circle detection
    gray = rgb2gray(enhanced);
    edges = edge(gray, 'canny', [0.1 0.25]);

    [cx, cy, radius] = detect_clock_circle(edges, gray);

    % Color segmentation
    [blueMask, redMask] = detect_color_masks(enhanced);

    [angleTo12, blueX, blueY] = detect_clock_orientation( ...
        blueMask, cx, cy);

    angleRed = detect_second_angle(redMask, cx, cy, radius);

    secondAngle = mod(angleRed - angleTo12, 360);
    seconds = mod(round(secondAngle / 6), 60);

    % Hough transform of black hands
    [A, thetaValues, rhoValues, blackMask] = ...
        detect_black_hands(gray, cx, cy, radius);

    votes = sum(A(abs(rhoValues) <= 3, :), 1);

    [~, index1] = max(votes);

    % Avoid detecting the same hand twice
    angleDifference = abs(thetaValues - thetaValues(index1));
    angleDifference = min(angleDifference, 180 - angleDifference);

    votes(angleDifference <= 8) = 0;

    [~, index2] = max(votes);

    theta1 = thetaValues(index1);
    theta2 = thetaValues(index2);

    % Determine hand directions and lengths
    blackHandPixels = blackMask & ~redMask;

    [angle1, length1] = get_black_hand_from_line( ...
        blackHandPixels, theta1, cx, cy, radius);

    [angle2, length2] = get_black_hand_from_line( ...
        blackHandPixels, theta2, cx, cy, radius);

    % The longer hand indicates minutes
    if length1 > length2
        angleMinute = angle1;
        minuteLength = length1;

        angleHour = angle2;
        hourLength = length2;
    else
        angleMinute = angle2;
        minuteLength = length2;

        angleHour = angle1;
        hourLength = length1;
    end

    % Correct for clock rotation
    minuteAngle = mod(angleMinute - angleTo12, 360);
    hourAngle = mod(angleHour - angleTo12, 360);

    % Read minutes
    minutes = mod(round((minuteAngle - 0.1 * seconds) / 6), 60);

    % Read hours and check consistency
    candidateHours = 0:11;

    expectedAngles = mod(30 * candidateHours + ...
        0.5 * minutes + seconds / 120, 360);

    errors = abs(mod(hourAngle - expectedAngles + 180, 360) - 180);

    [hourError, index] = min(errors);

    hours = candidateHours(index);

    if hours == 0
        hours = 12;
    end

    consistent = hourError <= 7.5;
    time = [hours, minutes, seconds];

    % Prepare color mask visualization
    maskRGB = zeros(size(enhanced));
    maskRGB(:,:,1) = redMask;
    maskRGB(:,:,3) = blueMask;

    % Visualization
    figure('WindowState', 'maximized');

    % 1. Original image
    subplot(2,3,1);
    imshow(I);
    title('Original image');

    % 2. Fourier spectrum
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

    % 3. Enhanced image
    subplot(2,3,3);
    imshow(enhanced);
    title('Enhanced image');

    % 4. Color masks
    subplot(2,3,4);
    imshow(maskRGB);
    title('Color masks');

    % 5. Hough accumulator
    subplot(2,3,5);
    imagesc(thetaValues, rhoValues, A);
    axis xy;
    colorbar;
    hold on;

    yline(0, 'r--', 'LineWidth', 1.5);

    centerRows = find(abs(rhoValues) <= 3);

    [~, peak1] = max(A(centerRows, index1));
    [~, peak2] = max(A(centerRows, index2));

    plot(theta1, rhoValues(centerRows(peak1)), 'co', ...
        'MarkerSize', 9, 'LineWidth', 2);

    plot(theta2, rhoValues(centerRows(peak2)), 'yo', ...
        'MarkerSize', 9, 'LineWidth', 2);

    hold off;

    xlabel('Theta (degrees)');
    ylabel('Rho (pixels)');
    title('Hough space of black hands');

    % 6. Final clock reading
    subplot(2,3,6);
    imshow(gray);
    hold on;

    theta = 0:359;

    circleX = cx + radius * cosd(theta);
    circleY = cy + radius * sind(theta);

    plot(circleX, circleY, 'g', 'LineWidth', 2);
    plot(cx, cy, 'r+', 'MarkerSize', 12, 'LineWidth', 2);

    % 12 o'clock marker
    plot([cx, blueX], [cy, blueY], ...
        'b-', 'LineWidth', 2);

    plot(blueX, blueY, 'bo', ...
        'MarkerSize', 8, 'MarkerFaceColor', 'b');

    % Second hand
    redX = cx + 0.8 * radius * cosd(angleRed);
    redY = cy + 0.8 * radius * sind(angleRed);

    plot([cx, redX], [cy, redY], 'r-', 'LineWidth', 2);

    % Minute hand
    minuteX = cx + minuteLength * cosd(angleMinute);
    minuteY = cy + minuteLength * sind(angleMinute);

    plot([cx, minuteX], [cy, minuteY], 'c-', 'LineWidth', 2);

    % Hour hand
    hourX = cx + hourLength * cosd(angleHour);
    hourY = cy + hourLength * sind(angleHour);

    plot([cx, hourX], [cy, hourY], 'y-', 'LineWidth', 3);

    hold off;

    if consistent
        title(sprintf('%02d:%02d:%02d', ...
            hours, minutes, seconds));
    else
        title(sprintf('%02d:%02d:%02d - BROKEN CLOCK', ...
            hours, minutes, seconds));
    end

    drawnow;

end
