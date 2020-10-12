function [img_low, img_high] = MgSoftThresholdSegment(img, th_low, th_high)
% [img_low, img_high] = MgSoftThresholdSegment(img, th_low, th_high)
% Segment images with soft threshold method.
% img: image to be segmented (2D or 3D).
% th_low: low threshold.
% th_high: high threshold.

img_low = zeros(size(img));
img_high = zeros(size(img));

idx_low = img < th_low;
idx_high = img > th_high;
idx_middle = ~idx_low & ~idx_high;

% low and high part
img_low(idx_low) = img(idx_low);
img_high(idx_high) = img(idx_high);

% intermediate part
img_high(idx_middle) = (img(idx_middle) - th_low) / (th_high - th_low)  .* img(idx_middle);
img_low(idx_middle) = img(idx_middle) - img_high(idx_middle);


end

