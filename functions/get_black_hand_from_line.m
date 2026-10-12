function [angleHand, handLength] = get_black_hand_from_line(blackMask, theta, cx, cy, radius)

    [y, x] = find(blackMask);

    dx = x - cx;
    dy = y - cy;

    distances = hypot(dx, dy);
    angles = mod(atan2d(dy, dx), 360);

    % Two possible directions of the Hough line
    angle1 = mod(theta + 90, 360);
    angle2 = mod(angle1 + 180, 360);

    % Angular distance to each direction
    diff1 = abs(mod(angles - angle1 + 180, 360) - 180);
    diff2 = abs(mod(angles - angle2 + 180, 360) - 180);

    % Pixels close to each direction
    pixels1 = diff1 < 4 & distances > 0.2 * radius;
    pixels2 = diff2 < 4 & distances > 0.2 * radius;

    % Choose the direction with more pixels
    if nnz(pixels1) >= nnz(pixels2)
        angleHand = angle1;
        handDistances = distances(pixels1);
    else
        angleHand = angle2;
        handDistances = distances(pixels2);
    end

    if isempty(handDistances)
        error('Hand not detected.');
    end

    handDistances = sort(handDistances);
    handLength = handDistances(ceil(0.95 * length(handDistances)));

end