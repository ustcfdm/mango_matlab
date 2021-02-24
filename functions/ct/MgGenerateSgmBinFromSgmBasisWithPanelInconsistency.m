function [sgm]  = MgGenerateSgmBinFromSgmBasisWithPanelInconsistency(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, acs_mode, panel_parameter_a, panel_parameter_b)
% [sgm, N_bin, N0_bin, N_res, N0_res, N]  = MgGenerateSinogram(sgm_basis, N0, energy, basisNames, basisConcentration, thresholds, addNoise, energyResponseMatrix)
% For a given basis sinogram and spectrum, generate sinogram within an energy bin.
% sgm: output sinogram [rows x cols x (bins+1)], [unitless], last one is full bin sinogram.
%
% sgm_basis: basis sinogram [rows x cols x slices], [mm]
% N0: spectrum [1 x 150]
% energy: [1 x 150], [keV]
% basisNames: name of each basis, string cell array (size: slices)
% basisConcentration: basis concentration [g/mL]
% thresholds: detector thresholds [keV]
% addNoise: whether to add noise to sinogram (bool)
% acs_mode: true (ACS on) or false (ACS off, i.e. single pixel mode)
% panel_parameter_a: (1d array) panel shift parameter a
% panel_parameter_b: (1d array) panel shift parameter b

% data dimensions
[rows, cols, basisCount] = size(sgm_basis);

% number of panels
panelCount = numel(panel_parameter_a);
% panel width
panelWidth = round(cols / panelCount);

% number of energy bins
binCount = numel(thresholds);

% output sinogram
sgm = zeros(rows, cols, binCount+1);

for idx = 1:panelCount
    % get energy response matrix
    enRes = MgGetEnergyResponseMatrix(acs_mode, panel_parameter_a(idx), panel_parameter_b(idx));
    
    % col index range
    idx_cols = (1:panelWidth) + (idx-1)*panelWidth;
    
    sgm(:, idx_cols, :) = MgGenerateSgmBinFromSgmBasis(sgm_basis(:,idx_cols,:), N0, energy, basisNames, basisConcentration, thresholds, addNoise, enRes);
    
end



end

