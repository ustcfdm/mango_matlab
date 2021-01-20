function [lsf, x] = MgGetLsfUnresample(img_2d, slope)
% [esf, x] = MgGetLsfUnresample(img_2d, slope)
% Get LSF (line spread function) curve from img_2d.
% img_2d: 2D image. Edge should be almost vertical with small angle tilt.
% slope: you can get it from function MgFindEdgeSlope(img_2d).
% lsf: LSF curve.
% x: x positions of lsf array.


img_2d = diff(img_2d, 1, 2);

[rows, cols] = size(img_2d);

x_2d = meshgrid(1:cols, 1:rows);
for row = 2:rows
    x_2d(row,:) = x_2d(row,:) - (row-1) * slope;
end

[x, idx] = sort(x_2d(:));
lsf = img_2d(idx);

end

