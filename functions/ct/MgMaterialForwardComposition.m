function [imgA, imgB] = MgMaterialForwardComposition(mu_matrix, img1, img2)
% Perform forward image basis converstion. For example:
%  img1, img2 are PMMA, Al basis, and imgA, imgB are water, Ca basis.
% mu_matrix: 2x2 matrix


[rows, cols, S] = size(img1);

imgAB = mu_matrix * cat(1, reshape(img1, 1, []), reshape(img2, 1, []));
imgA = reshape(imgAB(1,:), rows, cols, S);
imgB = reshape(imgAB(2,:), rows, cols, S);


end