function bin_spectrum = MgGetBinResponseSpectrum(spectrum, energy, threshold_low, threshold_high, a, b)
% For a given spectrum, return detected spectrum with detector energy response.
% spectrum: array of photon counts.
% energy: [keV].
% threshold_low: low threshold [keV] (included).
% threshold_high: high threshold [keV] (not included).
% bin_spectrum: respond spectrum in energy bin [threshold_low,threshold_high)
% a, b: shift coefficients of energy (a*E + b)

if nargin <= 4
    enRes = MgGetEnergyResponseMatrix();
else
    enRes = MgGetEnergyResponseMatrix(a, b);
end

en = interp1(squeeze(energy), squeeze(spectrum), 1:120);
en(isnan(en)) = 0;

bin = sum(enRes(threshold_low:threshold_high,:), 1);
bin = interp1(1:120, bin, energy);

bin_spectrum = spectrum .* bin;

end
