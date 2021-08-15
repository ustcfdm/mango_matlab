function [obj_folder_pmma, obj_folder_Al] = MgBenchtopDualEnergyDecompBiasCorr_0CountZbin(config_filename, order_corr, scale)
% Perform projection domain material decomposition and generate sinogram for benchtop PCD-CT system.
% Apply bias correction for LE, HE data.

js = MgReadJsoncFile(config_filename);
%% correction coefficients from order 1 to 4
corr_coeff = [-1/2, 1/12, 0, -120];
order_str = {'1st', '2nd', '3rd', '4th'};

%% folders to save decomp sinogram and img (w/ and w/o rebin)
obj_folder_pmma = sprintf('DE/PMMA_decomp_bias_corr_%s_order_scale=%.2f', order_str{order_corr}, scale);
obj_folder_Al = sprintf('DE/Al_decomp_bias_corr_%s_order_scale=%.2f', order_str{order_corr}, scale);

folder_sgm_PMMA = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_pmma);
folder_sgm_Al = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_Al);

MgMkdir(folder_sgm_PMMA, false);
MgMkdir(folder_sgm_Al, false);

%% load panel correction parameters
load(sprintf('%s/cali_DE.mat', MgBenchtopGetPanelCorrProtocolFolder(js.PanelCorrProtocol)));
cali_PMMA = cali_PMMA{2, 2};
cali_Al = cali_Al{2, 2};

%=========================================================
% read files and do decomposition
%=========================================================
% read EVI air data
file_air_LE = sprintf('./EVI/%s/air_LE.EVI', js.AirName);
file_air_HE = sprintf('./EVI/%s/air_HE.EVI', js.AirName);
if ~isfile(file_air_LE)
    file_air_TE = sprintf('./EVI/%s/air_TE.EVI', js.AirName);
    MgConvertHeTeToLe(file_air_TE, file_air_HE, file_air_LE);
end
prj_air_LE = mean(MgReadEviData(file_air_LE), 3);
prj_air_HE = mean(MgReadEviData(file_air_HE), 3);

% axial width after rebin
widthRebin = size(prj_air_HE,2) / js.RebinSize;

% obj file names
[files_TE_short, files_TE_long] = MgDirRegExpV2(sprintf('./EVI/%s', js.ObjectName), sprintf('%s_TE.EVI', js.ObjectIndex));
[files_HE_short, files_HE_long] = MgDirRegExpV2(sprintf('./EVI/%s', js.ObjectName), sprintf('%s_HE.EVI', js.ObjectIndex));

for n = 1:numel(files_HE_short)
    %-------------------------------------------
    % Step 1: read EVI and take log
    %-------------------------------------------
    file_LE = strrep(files_HE_long{n}, '_HE.EVI', '_LE.EVI');
    if ~isfile(file_LE)
        MgConvertHeTeToLe(files_TE_long{n}, files_HE_long{n}, file_LE);
    end

    %--------------------
    % bias corr for LE
    %--------------------
    prj_LE = MgReadEviData(file_LE);
    prj_fill_LE = mean(prj_LE((0:js.SliceThickness*js.SliceCount-1)+js.SliceStartIdx,:,:), 1) .* ones(js.EviHeight,1,1);
    idx_0_LE = prj_LE < 1;
    prj_LE(idx_0_LE) = prj_fill_LE(idx_0_LE)*scale; 
    
    % take log
    prj_log_LE = log(prj_air_LE ./ prj_LE);
    
    % apply bias correction
    for od = 1:order_corr
        prj_log_LE(~idx_0_LE) = prj_log_LE(~idx_0_LE) + corr_coeff(od) ./ (prj_LE(~idx_0_LE).^od);
    end
    
    prj_log_LE(isnan(prj_log_LE)) = 0;
    prj_log_LE(isinf(prj_log_LE)) = 0;
    
    % save memory
    clear prj_LE prj_fill_LE idx_0_LE
    
    %--------------------
    % bias corr for HE
    %--------------------
    prj_HE = MgReadEviData(files_HE_long{n});
    prj_fill_HE = mean(prj_HE((0:js.SliceThickness*js.SliceCount-1)+js.SliceStartIdx,:,:), 1) .* ones(js.EviHeight,1,1);
    idx_0_HE = prj_HE < 1;
    prj_HE(idx_0_HE) = prj_fill_HE(idx_0_HE)*scale; 
    
    % take log
    prj_log_HE = log(prj_air_HE ./ prj_HE);
    
    % apply bias correction
    for od = 1:order_corr
        prj_log_HE(~idx_0_HE) = prj_log_HE(~idx_0_HE) + corr_coeff(od) ./ (prj_HE(~idx_0_HE).^od);
    end
    
    prj_log_HE(isnan(prj_log_HE)) = 0;
    prj_log_HE(isinf(prj_log_HE)) = 0;
    
    % save memory
    clear prj_HE prj_fill_HE idx_0_HE

    %-------------------------------------------
    % Step 2: do the DE decomposition
    %-------------------------------------------
    prj_PMMA = MgPolyvalTwoVariable(cali_PMMA, prj_log_LE, prj_log_HE);
    prj_Al = MgPolyvalTwoVariable(cali_Al, prj_log_LE, prj_log_HE);
    
    prj_PMMA(isnan(prj_PMMA)) = 0;
    prj_PMMA(isinf(prj_PMMA)) = 0;
    prj_Al(isnan(prj_Al)) = 0;
    prj_Al(isinf(prj_Al)) = 0;
    
    %-------------------------------------------
    % Step 3: reslice to sinogram shape
    %-------------------------------------------
    sgm_PMMA = MgResliceProjectionToSinogram(prj_PMMA, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    sgm_Al = MgResliceProjectionToSinogram(prj_Al, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    
    sgm_PMMA = MgInterpSinogram(sgm_PMMA, 1, 2, 4);
    sgm_Al = MgInterpSinogram(sgm_Al, 1, 2, 4);
    
    %-------------------------------------------
    % Step 4: rebin sinogram
    %------------------------------------------
    sgm_PMMA_rebin = MgRebinSinogram(sgm_PMMA, js.RebinSize);
    sgm_Al_rebin = MgRebinSinogram(sgm_Al, js.RebinSize);
    
    % save to file
    filename = strrep(files_HE_short{n}, '_HE.EVI', sprintf('_%d-%d-%d.raw', widthRebin, js.Views, js.SliceCount));
    MgSaveRawFile(sprintf('%s/sgm_%s', folder_sgm_PMMA, filename), sgm_PMMA_rebin);
    MgSaveRawFile(sprintf('%s/sgm_%s', folder_sgm_Al, filename), sgm_Al_rebin);
end

end

