function p = MgPolyfit1D(x, y, orders)
% Perform polynomial fitting with abitrary specified order term.
% x: 1d array
% y: 1d array
% orders: the orders you want to use for fitting, e.g.
%          orders = [3, 2, 1, -1]
%          y = c1*x^3 + c2*x^2 + c3*x + c4*x^-1
% p: the coefficients corresponding to each order term (c1, c2 ...)

x = reshape(x, [], 1);
y = reshape(y, [], 1);

m = numel(x);
n = numel(orders);

% matrix to cat 
xx = zeros(m, n);

for col = 1:n
    xx(:, col) = x.^orders(col);
end

p = (xx' * xx) \ xx' * y;

end