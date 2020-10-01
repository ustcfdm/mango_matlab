function A = MgConstructPolyMatrix(order, v1, v2, hasZeroOrder)
% MgConstructPolyMatrix(order, v1, v2, hasZeroOrder)
% Construct a matrix A from two 1-D array v1, v2, the highest power is order
% e.g. A = cat(2, v1, v2, v1.^2, v1.^v2, v2.^2)
% ordder: highest power, no less than 1
% v1, v2: two vectors, no need to be column vectors. They will be reshape to
% column vector.
% hasZeroOrder: (optional) true or false, default is true

if nargin < 4
    hasZeroOrder = true;
end

% reshape
v1 = reshape(v1, [], 1);
v2 = reshape(v2, [], 1);

% cat the first order
if hasZeroOrder
    A = cat(2, ones(numel(v1), 1), v1, v2);
else
    A = cat(2, v1, v2);
end

% cat other order
for n = 2:order
    for k = n:-1:0
        A = cat(2, A, v1.^k.*v2.^(n-k));
    end
end


end