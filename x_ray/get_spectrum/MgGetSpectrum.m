function N = MgGetSpectrum(kVp, energy)
% function N = MgGetSpectrum(kVp, energy)
% Get the spectrum for a certain kVp. Intrinsical Al 3mm and air 1m is applied.
% kVp: kVp, from 50 to 140 kVp, 5 keV interval.
% energy: array of energy (keV).
% N: output spectrum (same size as energy);

filename = sprintf("spectrum_air_%d.txt", kVp);

if ~exist(filename, 'file')
	error("%d kVp is not available!\n", kVp);
    return
end

data = importdata(filename);
N = interp1(data(:,1), data(:,2), energy);

end