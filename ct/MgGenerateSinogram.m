function sgm = MgGenerateSinogram(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, useEnergyResponse)
% For a given basis sinogram and spectrum, generate sinogram within a
% energy bin.
% sgm: output sinogram [rows x cols x bins], [unitless]
% sgm_basis: basis sinogram [rows x cols x slices], [mm]
% N0: spectrum [1 x n]
% energy: [1 x n], [keV]
% basisNames: name of each basis, string array (size: slices)
% basisConcentration: basis concentration [g/mL]
% thresholds: detector thresholds [keV]
% addNoise: whether to add noise to sinogram (bool)
% useEnergyResponse: whether to use detector energy response (bool)

% data dimensions
[rows, cols, basisCount] = size(sgm_basis);
n = numel(energy);
binCount = numel(thresholds);

% get linear attenuation of bases
mu = zeros(1, n, basisCount);
for idx = 1:basisCount
    mu(1, :, idx) = MgGetLinearAttenuation(basisNames(idx), energy) * basisConcentration(idx) / MgGetMaterialDensity(basisNames(idx));
end

% calculate muL for sinogram
sgm_basis = reshape(sgm_basis, rows*cols, 1, basisCount);
muL = sgm_basis/10 .* mu;
muL = sum(muL, 3);

% spectrum after object
N = N0 .* exp(-muL);

% detector energy response
if useEnergyResponse
    enres = MgGetEnergyResponseMatrix();
else
    enres = eye(120);
end

% get detector sensitivity
sens = zeros(1, n, binCount);
sensFull = zeros(binCount, 120);
thresholds(end+1) = max(energy)+1;
for k = 1:binCount
    sensFull(k,:) = sum(enres(thresholds(k):thresholds(k+1)-1, :), 1);
    sens(1,:,k) = interp1(1:120, sensFull(k,:), energy);
end

% detector output spectrum after object
N_res = sum(N.*sens, 2);

% detector output spectrum before object
N0_res = sum(N0.*sens, 2);

% add noise or not
if addNoise
    N_res = poissrnd(N_res);
end
N_res(N_res<0.01) = 0.01;

% get sinogram
sgm = log(N0_res ./ N_res);
sgm = reshape(sgm, rows, cols, binCount);

end

