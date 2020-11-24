function img_darkfield = MgDpcDarkField(prj_3d, air_3d)
%

M = size(prj_3d, 3);

k = 1:M;
k = reshape(k, 1, 1, M);

prj_N1 = sum(prj_3d.*sin(2*pi*k/M), 3).^2 + sum(prj_3d.*cos(2*pi*k/M), 3).^2;
prj_N1 = 2/M * sqrt(prj_N1);

air_N1 = sum(air_3d.*sin(2*pi*k/M), 3).^2 + sum(air_3d.*cos(2*pi*k/M), 3).^2;
air_N1 = 2/M * sqrt(air_N1);


% log and subtract attenuation
img_darkfield = log(air_N1./prj_N1) - log(mean(air_3d,3) ./ mean(prj_3d,3));

end