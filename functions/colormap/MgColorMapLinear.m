function c = MgColorMapLinear(rgb, m)
%c =  MgColorMapLinear(rgb, m)
% rgb: an array with three numbers indicating the RGB value.
%   MgColorMapLinear(rgb, m) returns an M-by-3 matrix containing a colormap with specified rgb color.
%   MgColorMapLinear, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB uses the length of the
%   default colormap.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(MgColorMapLinear([1,0,0])
%


if nargin < 2
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

if nargin < 1
    rgb = [1, 1, 1];
end

ratio = (0:m-1)'/max(m-1,1); 
c = [ratio*rgb(1), ratio*rgb(2), ratio*rgb(3)];
