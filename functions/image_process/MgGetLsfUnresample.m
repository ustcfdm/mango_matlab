function [lsf, x] = MgGetLsfUnresample(img_2d, slope)
% [esf, x] = MgGetLsfUnresample(img_2d, slope)
% Get LSF (line spread function) curve from img_2d.
% slope: you can get it from function MgFindEdgeSlope(img_2d).



img_2d = diff(img_2d, 1, 2);

[rows, cols] = size(img_2d);

x_2d = meshgrid(1:cols, 1:rows);
for row = 2:rows
    x_2d(row,:) = x_2d(row,:) - (row-1) * slope;
end

% figure
% plot(x_2d(:), img_2d(:), '.')

[x, idx] = sort(x_2d(:));
lsf = img_2d(idx);

% align LSF to center


% [~, idx_center] = max(lsf);
% x = x - x(idx_center);

% figure
% plot(x, esf)

end

