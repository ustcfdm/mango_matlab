function matrix = MgDiskMatrix(r)
% matrix = MgDiskMatrix(r)
% Create a disk matrix with radius r.

% if ~isinteger(r)
%     error('r must be a integer!\n');
% end

N = 2 * r + 1;

[x, y] = meshgrid(-r:r);

matrix = zeros(N);

idx = (x.^2 + y.^2 <= r.^2);

matrix(idx) = 1;


end

