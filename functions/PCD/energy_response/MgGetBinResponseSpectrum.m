function bin_spectrum = MgGetBinResponseSpectrum(spectrum, energy, threshold_low, threshold_high, acs_mode, a, b)
% For a given spectrum, return detected spectrum with detector energy response.
% spectrum: array of photon counts.
% energy: [keV].
% threshold_low: low threshold [keV] (included).
% threshold_high: high threshold [keV] (not included).
% acs_mode:  true or false, wether use Anti-Charge sharing (ACS) mode
% bin_spectrum: respond spectrum in energy bin [threshold_low,threshold_high)
% a, b: shift coefficients of energy (a*E + b)

if nargin < 5
    acs_mode = true;
end

if nargin <= 5
    enRes = MgGetEnergyResponseMatrix(acs_mode);
else
    enRes = MgGetEnergyResponseMatrix(acs_mode, a, b);
end

en = interp1(squeeze(energy), squeeze(spectrum), 1:150);
en(isnan(en)) = 0;

bin = sum(enRes(threshold_low:threshold_high,:), 1);
bin = interp1(1:150, bin, energy);

bin_spectrum = spectrum .* bin;

end
