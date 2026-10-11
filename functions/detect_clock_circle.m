
function [maxX, maxY, radius] = detect_clock_circle(edges)
%DETECT_CLOCK_CIRCLE Detect the clock circle using the Hough transform.
% Input:
%   edges  - Binary edge map obtained using Canny.
% Outputs:
%   maxX   - Horizontal coordinate of the detected center.
%   maxY   - Vertical coordinate of the detected center.
%   radius - Radius of the detected circle.

    [rows, cols] = size(edges);

    % Get coordinates of edge pixels
    [edgeRows, edgeCols] = find(edges);

    minRadius = 100;
    maxRadius = 260;

    angles = 0:359;
    cosValues = cosd(angles);
    sinValues = sind(angles);

    bestVotes = 0;
    maxX = 0;
    maxY = 0;
    radius = 0;

    % Hough transform to find the circle
    for r = minRadius:maxRadius

        accumulator = zeros(rows, cols);

        for p = 1:length(edgeRows)

            x = edgeCols(p);
            y = edgeRows(p);

            for a = 1:length(angles)

                centerX = round(x - r * cosValues(a));
                centerY = round(y - r * sinValues(a));

                if centerX >= 1 && centerX <= cols && ...
                   centerY >= 1 && centerY <= rows

                    accumulator(centerY, centerX) = ...
                        accumulator(centerY, centerX) + 1;

                end

            end
        end

        % Find the center with the most votes for this radius
        [votes, index] = max(accumulator(:));

        if votes > bestVotes

            bestVotes = votes;
            [maxY, maxX] = ind2sub(size(accumulator), index);
            radius = r;

        end

    end

end
