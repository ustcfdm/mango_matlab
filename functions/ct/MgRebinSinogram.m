function sgmRebin= MgRebinSinogram(sgmData, rebinSize)
% Rebin the sinogram data along detector direction.
% sgmData: 2D or 3D sinogram data (views x cols x slices).
% rebinSize: rebin size.

rows = size(sgmData, 1);
cols = size(sgmData, 2);
slices = size(sgmData, 3);

sgmRebin = zeros(rows, floor(cols/rebinSize), slices);

for col = 1:cols/rebinSize
    sgmRebin(:,col,:) = mean(sgmData(:, col*rebinSize-rebinSize+1:col*rebinSize,:), 2);
end

end

