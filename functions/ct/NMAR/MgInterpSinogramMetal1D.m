function sgm_corr = MgInterpSinogramMetal1D(sgm_raw, sgm_idx_interp, sgm_prior)
% Inpterpolate sgm_raw at given region sgm_idx_interp. This is part of normalized metal artifact reduction (NMAR) process.
% sgm_raw: [rows x cols x pages] sinogram to be interpolated.
% sgm_idx_interp: [rows x cols x pages] (logic) index of metal region.
% sgm_prior: (optional) [rows x cols x pages] prior sinogram for normalization.

[rows, cols, pages] = size(sgm_raw);

if nargin < 3
    sgm_prior = 1;
end

%-------------------------------------
% normalize sinogram
%-------------------------------------
sgm_norm = sgm_raw ./ sgm_prior;
sgm_norm(isnan(sgm_norm)) = 0;
sgm_norm(isinf(sgm_norm)) = 0;

%-------------------------------------
% do the interpolation
%-------------------------------------
for page = 1:pages
    for row = 1:rows
        idx_metal = find(sgm_idx_interp(row,:,page));
        
        idx_group = MgMergeContinuousIndex(idx_metal);
        
        for g = 1:numel(idx_group)
            idx_left = idx_group{g}(1)-1;
            idx_right = idx_group{g}(2)+1;
            idx_between = idx_group{g}(1):idx_group{g}(2);
            
            sgm_norm(row, idx_between, page) = interp1([idx_left,idx_right], [sgm_norm(row,idx_left,page),sgm_norm(row,idx_right,page)], idx_between);
        end
    end
end

sgm_corr = sgm_norm .* sgm_prior;
    

end

