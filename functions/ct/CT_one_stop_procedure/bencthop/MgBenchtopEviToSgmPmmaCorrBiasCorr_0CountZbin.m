function [obj_folder_pmma_corr, obj_folder_no_corr] = MgBenchtopEviToSgmPmmaCorrBiasCorr_0CountZbin(config_filename, order_corr, scale)
% Generate sinogram from EVI data. Apply panel correction using pure PMMA. For 0-count pixels, replace them with z
% binning average value multiplied with a scale.
% Apply signal bias correcion:
%      <log(N)> = log(<N>) - 1/(2N) + 1/12/N^2 + 0/N^3 -1/120/N^4
% order_corr: order degree of correction (from 1 to 4)
% scale: multiply a scale for 0-count pixels after replacing with z binning (average)

js = MgReadJsoncFile(config_filename);

%% correction coefficients from order 1 to 4
corr_coeff = [-1/2, 1/12, 0, -120];
order_str = {'1st', '2nd', '3rd', '4th'};

%% folder names for sinogram (w and w/o PMMA correction)
obj_folder_pmma_corr = sprintf('%s/PMMA_corr_bias_corr_%s_order_scale=%.2f', js.EnergyBin, order_str{order_corr}, scale);
obj_folder_no_corr = sprintf('%s/no_corr_bias_corr_%s_order_scale=%.2f', js.EnergyBin, order_str{order_corr}, scale);

folder_sgm_pmma_corr = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_pmma_corr);
folder_sgm_no_corr = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_no_corr);

MgMkdir(folder_sgm_pmma_corr, false);
MgMkdir(folder_sgm_no_corr, false);

%% load panel correction parameters
filename = sprintf('%s/cali_PMMA.mat', MgBenchtopGetPanelCorrProtocolFolder(js.PanelCorrProtocol));
cali_PMMA = load(filename, sprintf('cali_PMMA_%s', js.EnergyBin)).(sprintf('cali_PMMA_%s', js.EnergyBin));

% read EVI air data
file_air = sprintf('./EVI/%s/air_%s.EVI', js.AirName, js.EnergyBin);
if js.EnergyBin == "LE" && ~isfile(file_air)
    file_air_TE = sprintf('./EVI/%s/air_TE.EVI', js.AirName);
    file_air_HE = sprintf('./EVI/%s/air_HE.EVI', js.AirName);
    MgConvertHeTeToLe(file_air_TE, file_air_HE, file_air);
end
prj_air = MgReadEviData(file_air);
prj_air = mean(prj_air, 3);


% obj EVI file names
[files_short, files_long] = MgBenchtopGetEviFileNames(js.ObjectName, js.ObjectIndex, js.EnergyBin);

% start processing
for n = 1:numel(files_short)
    fprintf('Processing file %s ...\n', files_short{n});
    
    %===========================================================
    % Step 1: EVI to prj_log (i.e. post-log)
    %===========================================================
    prj = MgReadEviData(files_long{n});
    prj = prj(:,:,1:js.Views);
    
    prj_fill = mean(prj((0:js.SliceThickness*js.SliceCount-1)+js.SliceStartIdx,:,:), 1) .* ones(js.EviHeight,1,1);
    
    % take log and remove extra views
    idx_0 = prj < 1;
    prj(idx_0) = prj_fill(idx_0)*scale; 
    
    prj_log = log(prj_air ./ prj);
    %-------------------------------
    % apply bias correction
    %-------------------------------
    for od = 1:order_corr
        prj_log(~idx_0) = prj_log(~idx_0) + corr_coeff(od) ./ (prj(~idx_0).^od);
    end
    
    % for 0 count part
%     corr_coeff2 = [1/2, 5/12, 3/4];
%     for od = 1:3
%         prj_log(idx_0) = prj_log(idx_0) + corr_coeff2(od) ./ (prj(idx_0).^od);
%     end
    
    prj_log(isnan(prj_log)) = 0;
    prj_log(isinf(prj_log)) = 0;
    
    %===========================================================
    % Step 2: do the pure PMMA panel correction
    %===========================================================
    prj_PMMA = MgPolyval(cali_PMMA, prj_log);
    prj_PMMA(isnan(prj_PMMA)) = 0;
    prj_PMMA(isinf(prj_PMMA)) = 0;
    
    %===========================================================
    % Step 3: reslice to sinogram shape
    %===========================================================
    sgm_no_corr = MgResliceProjectionToSinogram(prj_log, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    sgm_pmma_corr = MgResliceProjectionToSinogram(prj_PMMA, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    
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

