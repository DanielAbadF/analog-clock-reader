function [maxX, maxY, radius] = detect_clock_circle(edges, gray)
%DETECT_CLOCK_CIRCLE Detect the clock circle using gradient-guided Hough.
% Inputs:
%   edges  - Binary Canny edge map.
%   gray   - Grayscale image.
% Outputs:
%   maxX   - Horizontal coordinate of the detected center.
%   maxY   - Vertical coordinate of the detected center.
%   radius - Detected circle radius.

    [rows, cols] = size(edges);

    % Get edge coordinates and image gradients
    [edgeRows, edgeCols] = find(edges);
    [Gx, Gy] = imgradientxy(gray, 'sobel');

    indices = sub2ind([rows, cols], edgeRows, edgeCols);

    gx = Gx(indices);
    gy = Gy(indices);

    magnitude = hypot(gx, gy);

    valid = magnitude > 1e-6;

    x = edgeCols(valid);
    y = edgeRows(valid);

    % Normalize gradient directions
    ux = gx(valid) ./ magnitude(valid);
    uy = gy(valid) ./ magnitude(valid);

    bestVotes = 0;
    maxX = 0;
    maxY = 0;
    radius = 0;

    % Gradient-guided circular Hough transform
    for r = 100:260

        centerX = [round(x + r*ux); round(x - r*ux)];
        centerY = [round(y + r*uy); round(y - r*uy)];

        validCenters = centerX >= 1 & centerX <= cols & ...
                       centerY >= 1 & centerY <= rows;

        centerX = centerX(validCenters);
        centerY = centerY(validCenters);

        indices = sub2ind([rows, cols], centerY, centerX);

        accumulator = accumarray(indices, 1, [rows*cols, 1]);

        [votes, index] = max(accumulator);

        if votes > bestVotes
            bestVotes = votes;
            [maxY, maxX] = ind2sub([rows, cols], index);
            radius = r;
        end

    end

end
