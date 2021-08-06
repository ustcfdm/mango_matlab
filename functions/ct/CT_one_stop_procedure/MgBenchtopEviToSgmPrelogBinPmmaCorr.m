function [obj_folder_pmma_corr, obj_folder_no_corr] = MgBenchtopEviToSgmPrelogBinPmmaCorr(config_filename)
% Generate sinogram from EVI data. Apply panel correction using pure PMMA.

js = MgReadJsoncFile(config_filename);

%% folder names for sinogram (w and w/o PMMA correction)
obj_folder_pmma_corr = sprintf('%s/prelog_bin_PMMA_corr', js.EnergyBin);
obj_folder_no_corr = sprintf('%s/prelog_bin_no_corr', js.EnergyBin);

folder_sgm_pmma_corr = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_pmma_corr);
folder_sgm_no_corr = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_no_corr);

MgMkdir(folder_sgm_pmma_corr, false);
MgMkdir(folder_sgm_no_corr, false);

%% load panel correction parameters
filename = sprintf('%s/cali_PMMA.mat', js.PanelCorrParamFolder);
cali_PMMA = load(filename, sprintf('cali_PMMA_%s', js.EnergyBin)).(sprintf('cali_PMMA_%s', js.EnergyBin));
% reslice calibration parameters
cali_PMMA = MgResliceCaliPcell(cali_PMMA, js.SliceStartIdx, js.SliceThickness, js.SliceCount);

% read EVI air data
file_air = sprintf('./EVI/%s/air_%s.EVI', js.AirName, js.EnergyBin);
if js.EnergyBin == "LE" && ~isfile(file_air)
    file_air_TE = sprintf('./EVI/%s/air_TE.EVI', js.AirName);
    file_air_HE = sprintf('./EVI/%s/air_HE.EVI', js.AirName);
    MgConvertHeTeToLe(file_air_TE, file_air_HE, file_air);
end
prj_air = MgReadEviData(file_air);
prj_air = mean(prj_air, 3);
prj_air = MgResliceProjectionToSinogram(prj_air, js.SliceStartIdx, js.SliceThickness, js.SliceCount);

% obj EVI file names
[files_short, files_long] = MgBenchtopGetEviFileNames(js.ObjectName, js.ObjectIndex, js.EnergyBin);

% start processing
for n = 1:numel(files_short)
    fprintf('Processing file %s ...\n', files_short{n});
    
    %===========================================================
    % Step 1: read EVI, remove extra views, reslice + z binning
    %===========================================================
    prj = MgReadEviData(files_long{n});
    prj = MgResliceProjectionToSinogram(prj(:,:,1:js.Views), js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    
    % take log and remove extra views
    sgm_no_corr = log(prj_air ./ prj);
    sgm_no_corr(isnan(sgm_no_corr)) = 0;
    sgm_no_corr(isinf(sgm_no_corr)) = 0;
    
    %===========================================================
    % Step 2: do the pure PMMA panel correction
    %===========================================================
    sgm_pmma_corr = MgPolyval(cali_PMMA, sgm_no_corr, false);
    sgm_pmma_corr(isnan(sgm_pmma_corr)) = 0;
    sgm_pmma_corr(isinf(sgm_pmma_corr)) = 0;
    
    % interpolate panel gap
    sgm_no_corr = MgInterpSinogram(sgm_no_corr, 1,2, 4);
    sgm_pmma_corr = MgInterpSinogram(sgm_pmma_corr, 1,2, 4);
    
    %===========================================================
    % Step 4: rebin sinogram
    %===========================================================
    sgm_no_corr_rebin = MgRebinSinogram(sgm_no_corr, js.RebinSize);
    sgm_pmma_corr_rebin = MgRebinSinogram(sgm_pmma_corr, js.RebinSize);
    
    % save sinogram
    filename = strrep(files_short{n}, '.EVI', sprintf('_%d-%d-%d.raw', js.EviWidth / js.RebinSize, js.Views, js.SliceCount));
    MgSaveRawFile(sprintf('%s/sgm_%s', folder_sgm_no_corr, filename), sgm_no_corr_rebin);
    MgSaveRawFile(sprintf('%s/sgm_%s', folder_sgm_pmma_corr, filename), sgm_pmma_corr_rebin);
end


end

