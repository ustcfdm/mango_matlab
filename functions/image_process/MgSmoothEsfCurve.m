function [esf_smooth, x_smooth] = MgSmoothEsfCurve(lsf, x, resampleInterval, smoothThickness)
% [esf_smooth, x_smooth] = MgSmoothEsfCurve(esf, x, resampleInterval, smoothThickness)
% Smooth ESF curve 

% resample interval
dx = resampleInterval;
% smooth thickness 
ds = smoothThickness;

x_smooth = x(1):dx:x(end);
esf_smooth = zeros(1, numel(x_smooth));

for n = 1:numel(x_smooth)-ds
    idx = x >= x_smooth(n) & x < x_smooth(n+ds);
    esf_smooth(n) = mean(lsf(idx));
end

% figure(1)
% plot(x_smooth(1:end-1), esf_smooth(1:end-1));
x_smooth = x_smooth(1:end-ds);
esf_smooth = esf_smooth(1:end-ds);

end

