
function [restored, spectrum, peakRows, peakCols] = remove_periodic_noise(I)
%REMOVE_PERIODIC_NOISE Remove periodic interference using Fourier filtering.
% Inputs:
%   I         - RGB image.
% Outputs:
%   restored  - Filtered RGB image.
%   spectrum  - Log-magnitude Fourier spectrum.
%   peakRows  - Rows of the removed frequency peaks.
%   peakCols  - Columns of the removed frequency peaks.


    % Compute Fourier spectrum
    gray = im2double(rgb2gray(I));

    F = fftshift(fft2(gray));
    spectrum = log(1 + abs(F));

    [rows, cols] = size(spectrum);


    % Exclude low frequencies around the center
    cy = floor(rows/2) + 1;
    cx = floor(cols/2) + 1;

    radius = 25;
    S_search = spectrum;

    for i = 1:rows
        for j = 1:cols
            if (i - cy)^2 + (j - cx)^2 < radius^2
                S_search(i,j) = -inf;
            end
        end
    end


    % Detect candidate peaks
    k = 6;

    [~, indices] = maxk(S_search(:), k);
    [peakRows, peakCols] = ind2sub(size(S_search), indices);


    % Calculate local peak prominence
    localRadius = 5;
    peakStrength = zeros(k, 1);

    for p = 1:k

        r = peakRows(p);
        c = peakCols(p);

        localSum = 0;
        count = 0;

        for i = max(1, r-localRadius):min(rows, r+localRadius)
            for j = max(1, c-localRadius):min(cols, c+localRadius)

                if i == r && j == c
                    continue;
                end

                localSum = localSum + spectrum(i,j);
                count = count + 1;

            end
        end

        localMean = localSum / count;
        peakStrength(p) = spectrum(r,c) - localMean;

    end


    % Select significant peaks
    threshold = 3;
    selected = peakStrength > threshold;


    % Remove selected frequencies from each RGB channel
    I_double = im2double(I);
    restored = zeros(size(I_double));

    for channel = 1:3

        F_channel = fftshift(fft2(I_double(:,:,channel)));

        for p = 1:k
            if selected(p)
                F_channel(peakRows(p), peakCols(p)) = 0;
            end
        end

        restored(:,:,channel) = real(ifft2(ifftshift(F_channel)));

    end

    peakRows = peakRows(selected);
    peakCols = peakCols(selected);

end
