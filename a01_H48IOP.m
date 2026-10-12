clear;
clc;
close all;

addpath("functions");

files = dir(fullfile("input", "*.png"));

if isempty(files)
    error('No input images found.');
end

N = length(files);

times = zeros(N, 3);
consistent = false(N, 1);

% Process all frames
for n = 1:N

    filename = fullfile("input", files(n).name);
    I = imread(filename);

    [times(n,:), consistent(n)] = read_clock(I);

    fprintf('%s: %02d:%02d:%02d | Consistent: %d\n', ...
        files(n).name, times(n,1), times(n,2), times(n,3), ...
        consistent(n));

end

% Convert times to seconds for chronological sorting
totalSeconds = times(:,1) * 3600 + ...
               times(:,2) * 60 + times(:,3);

validIndices = find(consistent);
brokenIndices = find(~consistent);

[~, order] = sort(totalSeconds(validIndices));
validIndices = validIndices(order);

% Place broken clock frames at the end
sortedIndices = [validIndices; brokenIndices];

% Print summary table
fprintf('\n');
fprintf(' #  %-8s %-10s %-10s %s\n', ...
    'file', 'time', 'elapsed', 'consistent');

previousTime = [];

for i = 1:length(sortedIndices)

    n = sortedIndices(i);

    h = times(n,1);
    m = times(n,2);
    s = times(n,3);

    if consistent(n)

        if isempty(previousTime)
            elapsed = '-';
        else
            difference = totalSeconds(n) - previousTime;

            elapsed = sprintf('%02d:%02d:%02d', ...
                floor(difference / 3600), ...
                floor(mod(difference, 3600) / 60), ...
                mod(difference, 60));
        end

        previousTime = totalSeconds(n);
        status = 'yes';

    else

        elapsed = 'broken';
        status = 'NO';

    end

    fprintf('%2d  %-8s %02d:%02d:%02d   %-10s %s\n', ...
        i, files(n).name, h, m, s, elapsed, status);

end
