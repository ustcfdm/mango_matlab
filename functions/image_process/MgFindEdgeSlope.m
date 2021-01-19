function slope = MgFindEdgeSlope(img_2d)
% tiltAngle = MgFindEdgeSlope(img_2d)
% Fing an image edge slope. x: row direction. y: col direction.
% img_2d: 2D image of an edge.
% slope: slope of the edge.

% find the edge
BW = edge(img_2d, 'Sobel');
% BW = edge(img_2d, 'Prewitt');

%=============================================
% If you encounter any bug, show this image
% figure
% imshow(BW)
%=============================================

rows = size(BW, 1);

x = 1:rows;
y = zeros(1, rows);

for row = 1:rows
    y(row) = mean(find(BW(row, :)));
end

p = polyfit(x, y, 1);

slope = p(1);


end

