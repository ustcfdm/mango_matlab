function sinogram = MgResliceProjectionToSinogram(prjData, idxRowStart, sliceThickness, sliceCount)
% MgResliceProjectionToSinogram(prjData, idxRowStart, sliceThickness, sliceCount)
% Reslice the projection data (rows x cols x views) into sinogram data (views x cols x slices)
% prjData: projection data (rows x cols x views)
% idxRowStart: first index of row for prjData (start from 1)
% sliceThickness: [integer] how many slices to bin along row direction.
% sliceCount: [integer] number of slices for you sinogram

[rows, cols, views] = size(prjData);

sinogram = zeros(views, cols, sliceCount);

for z = 1:sliceCount
    idx = idxRowStart + (z-1) * sliceThickness;
    sinogram(:,:,z) = permute(mean(prjData(idx:idx+sliceThickness-1, :, :), 1), [3, 2, 1]);
end


end
