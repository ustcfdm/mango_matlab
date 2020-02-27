function msg = MgWriteImage(filename, data, windowRange, map)
% MgWriteImage(filename, data, windowRange, map)
% This function write your index image data to an image file.
% filename: e.g. 'name.png', 'name.jpg'...
% data: 2D image data.
% windowRange: window level [low high], or [] to use default window (optional)
% map: colormap, e.g. hot(256), jet(256) ... (optional)

% check whether windowRange is specified
if nargin < 3 || (nargin >= 3 && isempty(windowRange))
    % window level not specified
    img = data;
else
    % window level specified
    img = (data - windowRange(1)) / (windowRange(2) - windowRange(1));
end

% check whether colormap is specified
if nargin < 4
    % if map is not specified
    imwrite(img, filename);    
else
    % if map is specified
    imwrite(img*256, map, filename);
end

end

