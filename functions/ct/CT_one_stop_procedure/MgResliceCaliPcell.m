function p = MgResliceCaliPcell(p_cell, sliceStartIdx, sliceThickness, sliceCount)
% Reslice calibration coefficient of p_cell in sinogram-consistent shape.
% p_cell: consistent with projection data size (e.g. 5120 x 64).

% reformat
N = numel(p_cell{1});
p = cell(size(p_cell{1}));
for n = 1:N
    p{n} = zeros(size(p_cell));
    
    for k = 1:numel(p{n})
        p{n}(k) = p_cell{k}(n);
    end
end

% reslice
for n = 1:numel(p)
    p{n}(isnan(p{n})) = 0;
    p{n}(isinf(p{n})) = 0;
    p{n} = MgResliceProjectionToSinogram(p{n}, sliceStartIdx, sliceThickness, sliceCount);
end

end

