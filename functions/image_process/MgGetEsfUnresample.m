function [esf, x] = MgGetEsfUnresample(img_2d, slope)
% [esf, x] = MgGetLsfUnresample(img_2d, slope)
% Get LSF (line spread function) curve from img_2d.
% slope: you can get it from function MgFindEdgeSlope(img_2d).

% img_2d = abs(diff(img_2d, 1, 2));

[rows, cols] = size(img_2d);

x_2d = meshgrid(1:cols, 1:rows);
for row = 2:rows
    % fprintf('row = %d\n', row);
    x_2d(row,:) = x_2d(row,:) - (row-1) * slope;
end

% figure
% plot(x_2d(:), img_2d(:), '.')

[x, idx] = sort(x_2d(:));
esf = img_2d(idx);

end

