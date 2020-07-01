function [img, info] = MgDicomRead(filename)
% [img, info] = MgDicomRead(filename)
% Read a DICOM file. The rescale intercept and slope will be applied to the image data.
% filename: DICOM file name.
% img: DICOM image.
% info: DICOM header tags.

img = dicomread(filename);

info = dicominfo(filename);

img = img * info.RescaleSlope + info.RescaleIntercept;


end

