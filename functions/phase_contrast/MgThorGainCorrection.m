function img_3d = MgThorGainCorrection(img_3d, img_ref, ref_roi_rows, ref_roi_cols)
% img_3d = MgThorGainCorrection(img_3d, img_ref)
% Perform gain correction of Thor dectector image, including spatial direction and time(frame) direciton.
% img_3d: img stack to be corrected.
% img_ref: reference 2D image for gain correction for sptial direction (x-y plane).
% ref_roi_rows,ref_roi_cols (optional): ROI of img_ref for calculating mean value for gain correction, e.g. 1:rows, 1:cols


%====================================================================
% spatial correction
%====================================================================
if nargin < 3
    ref_mean = mean(img_ref, 'all');
else
    ref_mean = mean(img_ref(ref_roi_rows, ref_roi_cols), 'all');
end

cali_ratio = ref_mean ./ img_ref;

img_3d = img_3d .* cali_ratio;

%====================================================================
% time/frame correction
%====================================================================

% TODO: check whether need to use cropped img_3d within ROI
val_z = squeeze(mean(img_3d, [1,2]));
val_z_filter = medfilt1(val_z, 5);
cali_ratio2 = reshape(val_z_filter./val_z, 1, 1, []);

img_3d = img_3d .* cali_ratio2;

end

