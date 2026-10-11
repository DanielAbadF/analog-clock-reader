
function restored = remove_periodic_noise(I)

    gray = im2double(rgb2gray(I));

    F = fftshift(fft2(gray));
    S = log(1 + abs(F));

    [rows, cols] = size(S);

    cy = floor(rows/2) + 1;
    cx = floor(cols/2) + 1;

    radius = 25;
    S_search = S;

    for i = 1:rows
        for j = 1:cols
            if (i - cy)^2 + (j - cx)^2 < radius^2
                S_search(i,j) = -inf;
            end
        end
    end

    k = 6;

    [~, indices] = maxk(S_search(:), k);
    [peakRows, peakCols] = ind2sub(size(S_search), indices);

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

                localSum = localSum + S(i,j);
                count = count + 1;

            end
        end

        localMean = localSum / count;
        peakStrength(p) = S(r,c) - localMean;

    end

    threshold = 3;
    selected = peakStrength > threshold;

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

end
