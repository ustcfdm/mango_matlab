function [lsf, x] = MgGetLsf(img_2d, x_interval, smoothThickness)
% (deprecated)

if nargin < 3
    smoothThickness = 20;
end
if nargin < 2
    x_interval = 0.05;
end

if img_2d(1,1) > img_2d(1,end)
    img_2d = flip(img_2d, 2);
end

% find edge slope
slope = MgFindEdgeSlope(img_2d);

% get LSF curve
[lsf, x] = MgGetLsfUnresample(img_2d, slope);

% figure
% plot(x, lsf)

% resample and smooth LSF curve
[lsf, x] = MgSmoothLsfCurve(lsf, x, x_interval, smoothThickness);

% align to center and adjust range
% find x_center
% len = 40;
% left = mean(esf(1:len));
% right = mean(esf(end-20:end));
% 
% esf_center = (left+right)/2;
% 
% [~, idx_center] = min(abs(esf-esf_center));
% x = x - x(idx_center);
% 
% 
% 
% x_new = x_range(1):x_interval:x_range(2);
% esf_new = interp1(x, esf, x_new);



end

