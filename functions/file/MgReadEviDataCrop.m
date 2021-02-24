function img = MgReadEviDataCrop(filename, fullWidth, fullHeight)
% Read EVI file data with crop. For example, the image is cropped from
% 5120x64 to 3000x60. This function will read it as full size (5120x64).
% The border will be set to 0.
% filename: EVI file name.
% fullWidth: full width (default: 5120).
% fullHeight: full height (default: 64).
% img: output image.

if nargin == 1
    fullWidth = 5120;
    fullHeight = 64;
end


info = MgReadEviInfo(filename);

dataType = MgConvertEviDataTypeToMatlabDataType(info.Image_Type);

img = zeros(fullHeight, fullWidth, info.Nr_of_images);
rows = (1:info.Height) + info.ROI_Y;
cols = (1:info.Width) + info.ROI_X;

img(rows, cols, :) = MgReadRawFile(filename, info.Height, info.Width, info.Nr_of_images, info.Offset_To_First_Image, info.Gap_between_iamges_in_bytes, dataType);


end

