function [sgm, N_bin, N0_bin, N_res, N0_res, N]  = MgGenerateSinogram(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, energyResponseMatrix)
% This function is deprecated.
% [sgm, N_bin, N0_bin, N_res, N0_res, N, N_no_noise]  = MgGenerateSinogram(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, useEnergyResponse)
% For a given basis sinogram and spectrum, generate sinogram within an energy bin.
% sgm: output sinogram [rows x cols x (bins+1)], [unitless], last one is full bin sinogram.
% N: spectrum after object with noise [rows x cols x energy]
% N0_res: detected spectrum of background/air [1 x 1 x energy]
% N_res: detected spectrum after object [rows x cols x energy]
% N0_bin: photon counts of background/air after binning [1 x 1 x (bins+1)], last one is full bin data.
% N_bin: photon counts of object after binning [rows x cols x (bins+1)], last one is full bin data.
% sgm_basis: basis sinogram [rows x cols x slices], [mm]
% N0: spectrum [1 x n]
% energy: [1 x n], [keV]
% basisNames: name of each basis, string cell array (size: slices)
% basisConcentration: basis concentration [g/mL]
% thresholds: detector thresholds [keV]
% addNoise: whether to add noise to sinogram (bool)
% useEnergyResponse: whether to use detector energy response (bool)

% data dimensions
[rows, cols, basisCount] = size(sgm_basis);
en = reshape(energy, 1, []);
n = numel(en);
N0 = interp1(energy, N0, en);
N0(isnan(N0)) = 0;
binCount = numel(thresholds);

% get linear attenuation of bases
mu = zeros(1, n, basisCount);
for idx = 1:basisCount
    mu(1, :, idx) = MgGetLinearAttenuation(basisNames{idx}, en) * basisConcentration(idx) / MgGetMaterialDensity(basisNames{idx});
end

% calculate muL for sinogram
sgm_basis = reshape(sgm_basis, rows*cols, 1, basisCount);
muL = sgm_basis/10 .* mu;
muL = sum(muL, 3);

% spectrum after object (no noise)
N = N0 .* exp(-muL);

% bin spectrum based on thresholds
N_bin = zeros(rows, cols, binCount+1);
N0_bin = zeros(1, 1, binCount+1);


thresholds(end+1) = max(en)+1;
for k = 1:binCount
    N_bin(:,:,k) = sum(N_res(:,:, thresholds(k):thresholds(k+1)-1), 3);
    N0_bin(:,:,k) = sum(N0_res(:,:,thresholds(k):thresholds(k+1)-1), 3);
end

N_bin(:,:,binCount+1) = sum(N_res(:,:,thresholds(1):end), 3);
N0_bin(:,:,binCount+1) = sum(N0_res(:,:,thresholds(1):end), 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add noise or not
if addNoise
    N_bin = MgPoissrndGpu(N_bin);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N_bin(N_bin<1) = 1;

% calculate sinogram
sgm = log(N0_bin ./ N_bin);

% reshape N and N_no_noise
N = reshape(N, rows, cols, n);

end

