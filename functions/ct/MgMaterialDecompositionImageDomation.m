function img_decomp = MgMaterialDecompositionImageDomation(img, mu_matrix)
% img_decomp = MgMaterialDecompositionImageDomation(img, mu_matrix)
% Perform image domain material decomposition.
% img: M x M x S (S is equal to the number of energy bins).
% mu_matrix: S x S (decomposition matrix).
% img_decomp: M x M x S (decomposed images, unitless).

[rows, cols, S] = size(img);
img_decomp = zeros(rows, cols, S);

for row = 1:rows
    for col = 1:cols
        mu_obj = reshape(img(row, col, :), S, 1);
        
        f_decomp = mu_matrix \ mu_obj;
        
        for s = 1:S
            img_decomp(row, col, s) = f_decomp(s);
        end
    end
end


end