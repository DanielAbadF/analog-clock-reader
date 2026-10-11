function enhaced = enhace_contrast(image)

    hsv_img = rgb2hsv(image);

    V = hsv_img(:, :, 3);

    vMax = max(V(:));
    vMin = min(V(:));

    V = (V - vMin) / (vMax - vMin);

    hsv_img(:, :, 3) = V;

   enhaced = hsv2rgb(hsv_img);
end