function varargout = MgMaterialDecomposition(mu_matrix, varargin)
% Perform image domain material decomposition. Example usage:
%  [img_water, img_Ca] = MgMaterialForwardComposition(mu_matrix, img_PMMA, img_Al)
% Take 2 basis composition as example, the equation is:
%  [imgA; imgB] = mu_matrix * [img1; img2]
% mu_matrix: 2x2 matrix

% number of basis
N = nargin - 1;

% image matrix (left hand side)
img_mat_left = zeros(N, numel(varargin{2}));
for n = 1:N
    img_mat_left(n, :) = varargin{n}(:);
end

% do the forward composition
img_mat_right = mu_matrix \ img_mat_left;

% reshpae image matrix (right hand side)
varargout = cell(1, N);
for n = 1:N
    varargout{n} = reshape(img_mat_right(n,:), size(varargin{2}));
end

end