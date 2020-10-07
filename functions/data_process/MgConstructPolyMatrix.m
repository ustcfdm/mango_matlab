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
a1 = reshape(v1, [], 1);
a2 = reshape(v2, [], 1);

n = numel(a1);

N = (3+order)*order/2;
k = 1;

if hasZeroOrder
    N = N + 1;    
    k = k + 1;
end

A = ones(n, N);

% cat the columns
for n = 1:order
    for p = n:-1:0
        A(:, k) = a1.^p.*a2.^(n-p);
        k = k + 1;
    end
end


end