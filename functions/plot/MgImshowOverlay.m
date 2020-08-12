function MgImshowOverlay(varargin)
% MgImshowOverlay(varargin)
% Show multiple images overlay with each other with specified window level
% and colormap/color.
% Example:
%       figure
%       MgImshowOverlay({img1, [low1, high1], colormap/color},
%                       {img2, [low2, high2], color}, ...)

% number of images to overlay
N = nargin;

%=====================================================
% show the first image
%=====================================================
cell1 = varargin{1};
n = numel(cell1);

% convert images to the specified window range
img = cell1{1};
window = cell1{2};
img = (img - window(1)) / (window(2) - window(1));

if n==2 || (n==3 && numel(cell1{3}) > 3)
    h = imshow(img);
    if n == 3
        colormap(cell1{3});
    end
else
    color = cell1{3};
    
    img_bg = zeros(size(img,1), size(img,2), 3) + reshape(color, [1,1,3]);
    h = imshow(img_bg);
    set(h, 'AlphaData', img)
end


hold on
for k = 2:N
    % show the rest images
    data_pack = varargin{k};
    img = data_pack{1};
    window = data_pack{2};
    color = data_pack{3};
    
    img = (img - window(1)) / (window(2) - window(1));
    
    img_bg = zeros(size(img,1), size(img,2), 3) + reshape(color, [1,1,3]);
    h = imshow(img_bg);
    set(h, 'AlphaData', img);
end
hold off

end

