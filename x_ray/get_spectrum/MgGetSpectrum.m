function N = MgGetSpectrum(kVp, energy, varargin)
% function N = MgGetSpectrum(kVp, energy, ...)
% Get the spectrum for a certain kVp. Intrinsical Al 3mm and air 1m is applied.
% kVp: kVp, from 50 to 140 kVp, 5 keV interval.
% energy: array of energy (keV).
% varargin: filtration for the spectrum. e.g. "Cu", 0.2 [mm]
% N: output spectrum (same size as energy);

filename = sprintf("spectrum_air_%d.txt", kVp);

if ~exist(filename, 'file')
	error("%d kVp is not available!\n", kVp);
end

data = importdata(filename);
N = interp1(data(:,1), data(:,2), energy);

for k = 1:2:numel(varargin)
    mu = MgGetLinearAttenuation(varargin{k}, energy);
    N = N .* exp(-mu* varargin{k+1}/10);
end