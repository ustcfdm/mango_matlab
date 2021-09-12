function prj = MgResliceSinogramToProjection(sgm, idxRowStart, prjHeight, axialBin, zBin)
% Reslice the sinogram data (views x cols x slices) into projection data (rows x cols x views).
% prjData: projection data (rows x cols x views)
% idxRowStart: first index of row for prjData (start from 1)
% prjHeight: projection image full height (i.e. number of rows);
% axialBin: bin size along axial (column) direction.
% zBin: bin size along z direction.

rows = prjHeight;
cols = size(sgm,2) * axialBin;
views = size(sgm,1);

prj = zeros(rows, cols, views);

prj((0:size(sgm,3)*zBin-1)+idxRowStart, :, :) = MgUnbinArray(permute(sgm, [3,2,1]), [zBin, axialBin]);

% TODO: or use imresize?
% prj((0:size(sgm,3)*zBin-1)+idxRowStart, :, :) = imresize(permute(sgm, [3,2,1]), [size(sgm,3)*zBin, cols]);


end

