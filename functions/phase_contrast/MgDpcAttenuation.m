function img_attenu = MgDpcAttenuation(prj_3d, air_3d)
%

img_attenu = log(mean(air_3d,3) ./ mean(prj_3d,3));

end