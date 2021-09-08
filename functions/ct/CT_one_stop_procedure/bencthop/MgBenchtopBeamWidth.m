function prj_align = MgBenchtopBeamWidth(prj_3d, speed, fps, scale)
% Align the projection for the purpose of measuring benchtop beam width.
% prj_3d: projection data.
% speed: inch per second (downward or positive 6D of parker is positive speed).
% fps: PCD frame rate.
% scale (optional): scale factor to make image smaller to save memory.

if nargin < 4
    scale = 1;
end

% PCD pixel size
dx = 0.1 / scale;
% PCD moving speed (mm/s)
v_y = - speed*25.4;
% PCD frame pitch (unit: pixel)
v_y = v_y / fps / dx;



prj_3d = imresize3(prj_3d, scale);

s = size(prj_3d, 3);

x = zeros(s, 1);
y = (1:s) * v_y;

rows = (1: (50*scale)) + round(7*scale);

prj_align = MgAlignStackWithShift(prj_3d(rows,:,:), x, y);

prj_align = mean(prj_align, 3, 'omitnan');

% prj_align = MgStackZProjectWithShift(prj_3d(rows,:,:), x, y, @mean);

end

