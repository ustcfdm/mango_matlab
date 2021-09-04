function [obj_folder_pmma, obj_folder_Al] = MgBenchtopDualEnergyDecomp(config_filename, badPixelCorr)
% Perform projection domain material decomposition and generate sinogram for benchtop PCD-CT system.

js = MgReadJsoncFile(config_filename);

if nargin < 2
    badPixelCorr = false;
end

%% folders to save decomp sinogram and img (w/ and w/o rebin)
obj_folder_pmma = 'DE/PMMA_decomp';
obj_folder_Al = 'DE/Al_decomp';

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
    prj_LE = MgReadEviData(file_LE);
    prj_HE = MgReadEviData(files_HE_long{n});
    
    % take log
    prj_log_LE = log(prj_air_LE ./ prj_LE);
    prj_log_LE(isnan(prj_log_LE)) = 0;
    prj_log_LE(isinf(prj_log_LE)) = 0;
    prj_log_HE = log(prj_air_HE ./ prj_HE);
    prj_log_HE(isnan(prj_log_HE)) = 0;
    prj_log_HE(isinf(prj_log_HE)) = 0;
    
    % save memory
    clear prj_LE prj_HE

    %-------------------------------------------
    % Step 2: do the DE decomposition
    %-------------------------------------------
    prj_PMMA = MgPolyvalTwoVariable(cali_PMMA, prj_log_LE, prj_log_HE);
    prj_Al = MgPolyvalTwoVariable(cali_Al, prj_log_LE, prj_log_HE);
    
    % apply bad pixel correction
    if badPixelCorr
        prj_PMMA = MgBenchtopBadPixelCorr(prj_PMMA);
        prj_Al = MgBenchtopBadPixelCorr(prj_Al);
    end
    
    % save memory
    clear prj_log_LE prj_log_HE
    
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

