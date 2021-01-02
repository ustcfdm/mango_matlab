function y = MgPolyval1D(x, p, orders)
% Calculate polynomial value x given the coefficients and orders.
% x: 1D array.
% p: coefficients of each term.
% orders: the order of each term.

n = numel(p);

y = 0;
for k = 1:n
    y = y + p(k) * x .^ orders(k);
end


end

