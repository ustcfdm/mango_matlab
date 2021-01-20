function [esf_out, x_out] = MgGetEsf(img_2d, x_range, x_interval, smoothThickness)
% Get ESF curve from a 2D edge image. 
% img_2d: 2D image. Edge should be almost vertical with small angle tilt.
% x_rage (optional): output x range (unit: pixel). (default: [-5, 5]).
% x_interval (optional): x sampling interval (default: 0.05 pixel).
% smoothThickness (optional): smooth ESF curve with mean filter (default: 20).
% esf_out: output ESF array.
% x_out: x positions of esf_out array.

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

%--------------------------------------------------
% align to center and adjust range
%--------------------------------------------------
% find x_center
len = 40;
left = mean(esf(1:len));
right = mean(esf(end-20:end));

esf_center = (left+right)/2;

[~, idx_center] = min(abs(esf-esf_center));

% shift center to position x=0
x = x - x(idx_center);

% re-interp esf
x_out = x_range(1):x_interval:x_range(2);
esf_out = interp1(x, esf, x_out);

end

