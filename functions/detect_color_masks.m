
function [blueMask, redMask] = detect_color_masks(I)
%DETECT_COLOR_MASKS Detect the blue marker and red second hand.
% Input:
%   I        - Enhanced RGB image.
% Outputs:
%   blueMask - Binary mask of the blue 12 o'clock marker.
%   redMask  - Binary mask of the red second hand.

    hsv_img = rgb2hsv(I);

    H = hsv_img(:,:,1);
    S = hsv_img(:,:,2);
    V = hsv_img(:,:,3);

    % Detect the blue 12 o'clock marker
    blueMask = (H > 0.55) & (H < 0.75) & ...
               (S > 0.3) & (V > 0.15);

    % Detect the red second hand
    redMask = ((H < 0.06) | (H > 0.94)) & ...
              (S > 0.3) & (V > 0.15);

end
