function [mtf, k, dk] = MgCalculateMtf1D(y, dx, padding_ratio)
% [nps, k] = MgMeasureNPS(image, dx)
% Calculate MTF for a given 1D data.

if nargin < 3
    padding_ratio = 1;
end

N = round(numel(y)*padding_ratio);

mtf = abs(fft(y, N));
mtf = mtf / mtf(1);


dk = 1 / (N * dx);
k = (0:N-1) * dk;


end

