function imgCorr= MgRingCorrectionSplit(img2d, r, th_low_1, th_high_1, th_diff_1, median_length_1, smooth_length_1, ...
                                          th_low_2, th_high_2, th_diff_2, median_length_2, smooth_length_2)
% imgCorr= MgRingCorrectionSplit(img2d, r, th_low_1, th_high_1, th_diff_1, median_length_1, smooth_length_1,
%                                          th_low_2, th_high_2, th_diff_2, median_length_2, smooth_length_2)
% Perform ring artifact correction. Split the image into 2 part. For pixels
% within radius "r", using parameter set 1; for pixels outside radius "r",
% use parameter set 2.
% img2d: 2d image data before ring correction.
% r: radius for split (unit: pixels).
% imgCorr: 2d image data after ring correction.
% th_low: threshold low.
% th_high: threshold high.
% th_diff: threshold of difference.
% median_length: length of median filter (radial direction) (interger).
% smooth_length: length of rectangle filter (angular direction) (interger).

%===============================================================
% Do the correction using two parameter sets
%===============================================================
img2d_corr_1 = MgRingCorrection(img2d, th_low_1, th_high_1, th_diff_1, median_length_1, smooth_length_1);
img2d_corr_2 = MgRingCorrection(img2d, th_low_2, th_high_2, th_diff_2, median_length_2, smooth_length_2);

%===============================================================
% split the image and merge
%===============================================================
nx = size(img2d, 2);
ny = size(img2d, 1);

x = (1:nx) - nx/2 - 0.5;
y = (1:ny) - ny/2 - 0.5;
y = y';

% calculate radius of each pixel
rr = sqrt(x.^2 + y.^2);

% idx within radius r
idx = rr <= r;

% merge correction result
imgCorr = img2d_corr_2;
imgCorr(idx) = img2d_corr_1(idx);


end

