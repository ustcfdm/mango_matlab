function img_align = MgAlignStackWithShift(img_stack, x_v, y_v, out_rows, out_cols)
% img_align = MgAlignStackWithShift(img_stack, x_v, y_v)
% Align image stack with spatial shift.
% img_stack: 3D image stack.
% x_v: 1D array specifying x shift distance of each slice (right direction is position, unit: pixel).
% y_v: 1D array specifying y shift distance of each slice (down direction is position, unit: pixel).
% out_raws, out_cols (optional): considering output image is very large,
% you can specify its index range, e.g. 100:500, 1:300.

[rows, cols, slices] = size(img_stack);

[xx, yy] = meshgrid(1:cols, 1:rows);

% prepare the output image stack
x_v = x_v - min(x_v);
y_v = y_v - min(y_v);

cols_out = ceil(cols + max(x_v) - min(x_v));
rows_out = ceil(rows + max(y_v) - min(y_v));
% output image stack pixel positions
if nargin < 4
    out_rows = 1:rows_out;
    out_cols = 1:cols_out;
end
[xx_out, yy_out] = meshgrid(out_cols, out_rows);
% output image stack
img_align = zeros(size(xx_out,1), size(xx_out,2), slices, class(img_stack));

% start the alignment
for s = 1:slices
    xx_s = xx + x_v(s);
    yy_s = yy + y_v(s);
    
    img_align(:,:,s) = interp2(xx_s, yy_s, img_stack(:,:,s), xx_out, yy_out);
end


end

