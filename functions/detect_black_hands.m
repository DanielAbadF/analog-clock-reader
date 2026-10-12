
function [A, thetaValues, rhoValues, blackMask] = detect_black_hands(gray, cx, cy, radius)
%Build the Hough accumulator of the black hands.

    gray = im2double(gray);

    [rows, cols] = size(gray);
    [X, Y] = meshgrid(1:cols, 1:rows);

    % Select dark pixels inside the dial
    distances = hypot(X - cx, Y - cy);
    interior = distances < 0.78 * radius;

    threshold = graythresh(gray(interior));
    blackMask = (gray < threshold) & interior;

    % Get black pixel coordinates relative to the clock center
    [y, x] = find(blackMask);

    x = x - cx;
    y = y - cy;

    % Hough parameter space
    thetaValues = 0:179;
    rhoMax = ceil(radius);
    rhoValues = -rhoMax:rhoMax;

    A = zeros(length(rhoValues), length(thetaValues));

    % Accumulate votes
    for t = 1:length(thetaValues)

        rho = round(x * cosd(thetaValues(t)) + ...
                    y * sind(thetaValues(t)));

        indices = rho + rhoMax + 1;

        A(:,t) = accumarray(indices, 1, [length(rhoValues), 1]);

    end

end
