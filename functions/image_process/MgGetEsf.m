function [esf_new, x_new] = MgGetEsf(img_2d, x_range, x_interval, smoothThickness)
%

if nargin < 4
    smoothThickness = 20;
end
if nargin < 3
    x_interval = 0.05;
end
if nargin < 2
    x_range = [-5, 5];
end

% find edge slope
slope = MgFindEdgeSlope(img_2d);

% get LSF curve
[lsf, x] = MgGetLsfUnresample(img_2d, slope);

% resample and smooth LSF curve
[lsf, x] = MgSmoothLsfCurve(lsf, x, x_interval, smoothThickness);

% cumsum to get ESF
esf = cumsum(lsf) * x_interval;

% align to center and adjust range
% find x_center
len = 40;
left = mean(esf(1:len));
right = mean(esf(end-20:end));

esf_center = (left+right)/2;

[~, idx_center] = min(abs(esf-esf_center));
x = x - x(idx_center);



x_new = x_range(1):x_interval:x_range(2);
esf_new = interp1(x, esf, x_new);



end

