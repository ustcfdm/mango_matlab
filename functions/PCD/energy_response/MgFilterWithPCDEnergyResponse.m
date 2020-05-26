function spectrum_out = MgFilterWithPCDEnergyResponse(spectrum_in, energy, a, b)
% Distort the spectrum with photon counting detecotr energy response
% function.
% spectrum_in: incident spectrum to the PCD.
% energy: corresponding energy of spectrum_in [keV].
% a, b: do a linear transformation of spectrum_out (a*spectrum_out + b)

% set enregy for data matrix
en = (1:120)';
% set spectrum for data matrix
N0 = interp1(energy(:), spectrum_in(:), en);
N0(isnan(N0)) = 0;

% import energy response data matrix
enRes = importdata('MgEnergyResponseData.txt');

% output spectrum
% N = sum(N0 .* enRes, 2);
N = enRes * N0;

% do a linear transformation if required
if nargin == 4
    en = a*en + b;
end

% justify array length of output spectrum
spectrum_out = interp1(en, N, energy);
spectrum_out = reshape(spectrum_out, size(spectrum_in));

spectrum_out(isnan(spectrum_out)) = 0;


end