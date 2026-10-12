function [angleTo12, blueX, blueY] = detect_clock_orientation(blueMask, cx, cy)
%Find the angular reference of the clock.

    [blueRows, blueCols] = find(blueMask);

    blueX = mean(blueCols);
    blueY = mean(blueRows);

    angleTo12 = mod(atan2d(blueY - cy, blueX - cx), 360);

end