function y = MgPolyval(p_cell, x, p_power)
% y = MgPolyval(p_cell, x, p_power)
% Perform polyval to x, faster than built-in polyval function.
% x: an n-D array.
% p_cell: the size of p_cell is the same as x size or consistent for .*
%         operator (i.e. element-wise broadcasting). Each cell element has the same
%         number of coefficients.
% p_power: (optional) the power corresponding to the coefficients in
%          p_cell. The default is in decreasing order. For example, if p_cell
%          element has 4 numbers, the default p_power is [3, 2, 1, 0].
% y: same size as x.

% number of coefficients for each element
N = numel(p_cell{1});

% defalut p_power
if nargin < 3
    p_power = N-1:-1:0;
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
y = zeros(size(x));
for n = 1:numel(p_power)
    y = y + p{n} .* (x .^ p_power(n));
end


end