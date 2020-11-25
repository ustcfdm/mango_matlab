function img_mu = MgConvertHUtoMu(img_HU, mu_water)
% MgConvertMuToHU(img_mu, mu_water)
% Convert image from mu unit to HU unit.
% img_mu: image (2d or 3d) in mu unit (e.g. mm-1, cm-1).
% img_water: mu of water.
% img_HU: image in HU unit.

img_mu = (img_HU/1000 + 1) * mu_water;

end