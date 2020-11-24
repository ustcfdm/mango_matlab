function img_phase = MgDpcPhaseContrast(prj_3d, air_3d)
%

M = size(prj_3d, 3);

k = 1:M;
k = reshape(k, 1, 1, M);

prj_phase = angle(sum(prj_3d.*cos(2*pi*k/M), 3) - 1i * sum(prj_3d.*sin(2*pi*k/M), 3));
air_phase = angle(sum(air_3d.*cos(2*pi*k/M), 3) - 1i * sum(air_3d.*sin(2*pi*k/M), 3));

img_phase = angle(exp(1i*(prj_phase - air_phase)));

end