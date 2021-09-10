function MgSetFigureSize(fig, width, height)
% Set figure size.

p = get(fig, 'Position');
set(fig, 'Position', [p(1), p(2), width, height]);

end

