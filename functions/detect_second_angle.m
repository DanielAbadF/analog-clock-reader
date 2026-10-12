function angleRed = detect_second_angle(redMask, cx, cy, radius)
%Estimate the direction of the red second hand.

    [redRows, redCols] = find(redMask);

    distances = hypot(redCols - cx, redRows - cy);

    % Keep the outer part of the second hand
    valid = distances >= 0.6 * radius & ...
            distances < 0.95 * radius;

    redRows = redRows(valid);
    redCols = redCols(valid);

    if isempty(redRows)
        error('Red second hand not detected.');
    end

    % Calculate and sort pixel angles
    angles = mod(atan2d(redRows - cy, redCols - cx), 360);
    angles = sort(angles);

    % Select the lower median
    angleRed = angles(ceil(length(angles) / 2));

end