function [img, info] = MgDicomReadVolume(folder)
% [img, info] = MgDicomRead(filename)
% Read a DICOM file. The image volume will be squeezed. The rescale intercept and slope will be applied to the image data.
% filename: DICOM file name.
% img: DICOM image.
% info: DICOM header tags.

% read image volume
img = squeeze(dicomreadVolume(folder));

% read header info
files = MgDirRegExp(folder, '.*');
file = sprintf('./%s/%s', folder, files{1});

info = dicominfo(file);

% sacle the image data
img = img * info.RescaleSlope + info.RescaleIntercept;


end

