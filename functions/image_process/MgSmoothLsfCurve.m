function [esf_smooth, x_smooth] = MgSmoothLsfCurve(lsf, x, resampleInterval, smoothThickness)
% [esf_smooth, x_smooth] = MgSmoothEsfCurve(esf, x, resampleInterval, smoothThickness)
% Smooth ESF curve with given smooth thickness.
% resampleInterval: x sampling interval (e.g. 0.05 pixel).
% smoothThickness: smooth thickness (unit: per resampleInterval).

% resample interval
dx = resampleInterval;
% smooth thickness 
ds = smoothThickness;

x_smooth = x(1):dx:x(end);
esf_smooth = zeros(1, numel(x_smooth));

for n = 1:numel(x_smooth)-ds
    idx = x >= x_smooth(n) & x < x_smooth(n)+ds*dx;
    esf_smooth(n) = mean(lsf(idx));
end

x_smooth = x_smooth(1:end-ds);
esf_smooth = esf_smooth(1:end-ds);

end

