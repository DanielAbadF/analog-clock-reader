function enhanced = enhace_contrast(image)
%ENHACE_CONTRAST Enhance image contrast using linear histogram stretching.
% Input:
%   image    - RGB image.
% Output:
%   enhanced - Contrast-enhanced RGB image.

    % Extract the brightness channel in HSV
    hsv_img = rgb2hsv(image);
    V = hsv_img(:, :, 3);

    % Stretch brightness values to [0, 1]
    vMax = max(V(:));
    vMin = min(V(:));

    if vMax > vMin
        V = (V - vMin) / (vMax - vMin);
    end

    hsv_img(:, :, 3) = V;

    enhanced = hsv2rgb(hsv_img);

end