function [sgm, N_bin, N0_bin, N]  = MgGenerateSgmBinFromSgmBasis(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, energyResponseMatrix)
% [sgm, N_bin, N0_bin, N_res, N0_res, N]  = MgGenerateSinogram(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, energyResponseMatrix)
% For a given basis sinogram and spectrum, generate sinogram within an energy bin.
% sgm: output sinogram [rows x cols x (bins+1)], [unitless], last one is full bin sinogram.
% N_bin: photon counts of object after binning [rows x cols x (bins+1)], last one is full bin data.
% N0_bin: photon counts of background/air after binning [1 x 1 x (bins+1)], last one is full bin data.
% N: spectrum after object without noise [rows x cols x energy]
%
% sgm_basis: basis sinogram [rows x cols x slices], [mm]
% N0: spectrum [1 x 150]
% energy: [1 x 150], [keV]
% basisNames: name of each basis, string cell array (size: slices)
% basisConcentration: basis concentration [g/mL]
% thresholds: detector thresholds [keV]
% addNoise: whether to add noise to sinogram (bool)
% energyResponseMatrix: energy response matrix (150 x 150)

% data dimensions
[rows, cols, basisCount] = size(sgm_basis);

n = numel(energy);
if n ~= 150
    error('Vector "energy" must be 1:150');
end

en = reshape(energy, 1, 1, []);
N0 = reshape(N0, 1, 1, []);

binCount = numel(thresholds);


%======================================================================
% spectrum after object
%======================================================================
% calculate muL
muL = zeros(rows, cols, n);
for k = 1:basisCount
    mu = MgGetLinearAttenuation(basisNames{k}, en) * basisConcentration(k) / MgGetMaterialDensity(basisNames{k});
    muL = muL + sgm_basis(:,:,k) .* mu / 10;
end
% spectrum after object (no noise)
N = N0 .* exp(-muL);

%======================================================================
% calculate bin sensitivity S
%======================================================================
S = zeros(binCount+1, 1, n);

thresholds(end+1) = max(en)+1;
for k = 1:binCount
    S(k,1,:) = reshape(sum(energyResponseMatrix(thresholds(k):thresholds(k+1)-1, :), 1), 1, 1, []);
end
S(k+1, 1, :) = reshape(sum(energyResponseMatrix(thresholds(1):end, :), 1), 1, 1, []);


%======================================================================
% calculate photon counts for each bin N_bin and N0_bin
%======================================================================
N_bin = zeros(rows, cols, binCount+1);
N0_bin = zeros(1, 1, binCount+1);

for b = 1:binCount+1
    N_bin(:,:,b) = sum(N .* S(b,1,:), 3);
    N0_bin(1,1,b) = sum(N0 .* S(b,1,:), 3);
end

% add noise
if addNoise
    N_bin = MgPoissrndGpu(N_bin);
end

% N_bin(N_bin<1) = 1;

%======================================================================
% calculate sinogram
%======================================================================
sgm = log(N0_bin ./ N_bin);
sgm(isnan(sgm)) = 0;
sgm(isinf(sgm)) = 0;

end

