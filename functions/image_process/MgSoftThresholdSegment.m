function [img_low, img_high] = MgSoftThresholdSegment(img, th_low, th_high, applyThreshold)
% [img_low, img_high] = MgSoftThresholdSegment(img, th_low, th_high)
% Segment images with soft threshold method.
% img: image to be segmented (2D or 3D).
% th_low: low threshold.
% th_high: high threshold.
% applyThreshold: (optional) true or false (default is false). 
%                 If true, [img_low, img_high] will be segmented images. 
%                 If false, [img_low, img_high] will ratio. Take product img.*img_low or img.*img_high to get final
%                 segmented images.

if nargin < 4
    applyThreshold = false;
end

img_low = zeros(size(img));
img_high = zeros(size(img));

idx_low = img < th_low;
idx_high = img > th_high;
idx_middle = ~idx_low & ~idx_high;

% low and high part
img_low(idx_low) = 1;
img_high(idx_high) = 1;

% intermediate part
img_high(idx_middle) = (img(idx_middle) - th_low) / (th_high - th_low);
img_low(idx_middle) = 1 - img_high(idx_middle);


if applyThreshold
    img_low = img .* img_low;
    img_high = img .* img_high;
end


end

