function varargout = MgMaterialForwardComposition(mu_matrix, varargin)
% Perform forward image basis converstion. Example usage:
%  [img_water, img_Ca] = MgMaterialForwardComposition(mu_matrix, img_PMMA, img_Al)
% Take 2 basis composition as example, the equation is:
%  [imgA; imgB] = mu_matrix * [img1; img2]
% mu_matrix: 2x2 matrix

% number of basis
N = nargin - 1;

% image matrix (right hand side)
img_mat_right = zeros(N, numel(varargin{2}));
for n = 1:N
    img_mat_right(n, :) = varargin{n}(:);
end

% do the forward composition
img_mat_left = mu_matrix * img_mat_right;

% reshpae image matrix (left hand side)
varargout = cell(1, N);
for n = 1:N
    varargout{n} = reshape(img_mat_left(n,:), size(varargin{2}));
end

end