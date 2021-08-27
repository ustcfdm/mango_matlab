function obj_folder_no_corr = MgBenchtopEviToSgm(config_filename, usePanelGapCorr)
% Generate sinogram from EVI data. No panel correction.

js = MgReadJsoncFile(config_filename);

if nargin < 2
    usePanelGapCorr = true;
end
    


%% folder names for sinogram (w/o PMMA correction)
obj_folder_no_corr = sprintf('%s/no_corr', js.EnergyBin);
folder_sgm_no_corr = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder_no_corr);
MgMkdir(folder_sgm_no_corr, false);

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
    
    % take log and remove extra views
    prj_log = log(prj_air ./ prj(:,:,1:js.Views));
    prj_log(isnan(prj_log)) = 0;
    prj_log(isinf(prj_log)) = 0;

    %===========================================================
    % Step 2: reslice to sinogram shape
    %===========================================================
    sgm_no_corr = MgResliceProjectionToSinogram(prj_log, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    
    % interpolate panel gap
    if usePanelGapCorr
        sgm_no_corr = MgInterpSinogram(sgm_no_corr, 1,2, 4);
    end
    
    %===========================================================
    % Step 4: rebin sinogram
    %===========================================================
    sgm_no_corr_rebin = MgRebinSinogram(sgm_no_corr, js.RebinSize);
    
    % save sinogram
    filename = strrep(files_short{n}, '.EVI', sprintf('_%d-%d-%d.raw', js.EviWidth / js.RebinSize, js.Views, js.SliceCount));
    MgSaveRawFile(sprintf('%s/sgm_%s', folder_sgm_no_corr, filename), sgm_no_corr_rebin);
end


end

