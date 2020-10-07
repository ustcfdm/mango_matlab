function z = MgPolyvalTwoVariable(p_cell, x, y)
% MgPolyvalTwoVariable(p_cell, x, y)
% Perform polyval to x and y.
% Example: 
%       z = c0 + c10.*x + c01.*y + c20.*x.^2 + c11.*x.*y + c02.*y.^2 + ...
% 
% x, y: n-D array.
% p_cell: the size of p_cell is the same as x and y size or consistent for .*
%         operator (i.e. element-wise broadcasting). Each cell element has the same
%         number of coefficients.
% z: same size as x and y.

% number of coefficients for each element
N = numel(p_cell{1});

% find fit order and whether contains zero order term
order = 1;
while order <= 100
    if N == (3+order)*order/2
        hasZeroOrder = false;
        break;
    elseif N == (3+order)*order/2 + 1
        hasZeroOrder = true;
        break;
    end        
    order = order + 1;
end
if order > 100
    error('Your order is too high (>100) or parameters are not correct!\n');
end

% reformat p_cell to p
p = cell(1, N);
for n = 1:N
    p{n} = zeros(size(p_cell));
    
    for k = 1:numel(p{n})
        p{n}(k) = p_cell{k}(n);
    end
end

% start polyval calculation
z = zeros(size(x));

k = 1;
% for zero order term
if hasZeroOrder
    z = z + p{k};
    k = k + 1;
end
% for other order terms
for n = 1:order
    for m = n:-1:0
        z = z + p{k} .* x.^m.*y.^(n-m);
        k = k + 1;
    end
end


end