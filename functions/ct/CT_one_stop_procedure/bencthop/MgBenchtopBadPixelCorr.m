function prj_3d = MgBenchtopBadPixelCorr(prj_3d)
% apply bad pixel correction for Hydra detector.

% 2x2 bad pixels
prj_3d(47,1720,:) = (prj_3d(46,1720,:) + prj_3d(47,1719,:)) / 2;
prj_3d(47,1721,:) = (prj_3d(46,1721,:) + prj_3d(47,1722,:)) / 2;
prj_3d(48,1720,:) = (prj_3d(49,1720,:) + prj_3d(48,1719,:)) / 2;
prj_3d(48,1721,:) = (prj_3d(49,1721,:) + prj_3d(48,1722,:)) / 2;


end

