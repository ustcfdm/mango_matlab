function MgNMAR_v2(config_NMAR_filename)
% Second version of NMAR. Compared with first version, it can automatically detect metal region. MAR will be performed
% before NMAR to generate the prior image.

% threshold for idenfying metal region in sinogram
small_number = 1e-7;

js = MgReadJsoncFile(config_NMAR_filename);
js_fbp = MgReadJsoncFile(js.fbp_config);
js_fpj = MgReadJsoncFile(js.fpj_config);
% folder for saving temporary files
folder_temp = sprintf('_NMAR_TEMP_%s', date);
MgMkdir(folder_temp, true);

folder_img_raw = js_fbp.OutputDir;

% switch OutputFileReplace order
str_rep = js_fbp.OutputFileReplace;
for n = 1:2:numel(str_rep)
    tmp = str_rep{n};
    str_rep{n} = str_rep{n+1};
    str_rep{n+1} = tmp;
end
js_fpj.OutputFileReplace = str_rep;

%=========================================================================================
% Step 1: reconstruct images to segment and circular crop images (if required).
%=========================================================================================
% reconstruct images
MgMkdir(js_fbp.OutputDir, true);
system(sprintf('mgfbp %s >NUL', js.fbp_config));
% detect metal ROI
files_img_raw = MgDirRegExp(js_fbp.OutputDir, '.*');
folder_metal_roi = sprintf('./%s/img_metal_roi', folder_temp);
MgMkdir(folder_metal_roi, true);
for n = 1:numel(files_img_raw)
    filename = sprintf('./%s/%s', js_fbp.OutputDir, files_img_raw{n});
    img = MgReadRawFile(filename, js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    
    % check whether want to circular crop FOV of images
    if isfield(js, 'CircularCropFOVRadius')
        fillValue = 0;
        if isfield(js_fbp, 'WaterMu')
            fillValue = -1000;
        end
        img = MgCropCircleFOV(img, js.CircularCropFOVRadius, fillValue);
    end
    
    % segment metal ROI
    img_metal_roi = zeros(size(img));
    
    idx_metal = img >= js.MetalRange(1) & img < js.MetalRange(2);
    
    % TODO: ajdust metal ROI using erosion/dilation
    disk = MgDiskMatrix(2);
    idx_metal = imdilate(idx_metal, disk);

    
    img_metal_roi(idx_metal) = 1;
    
    % save metal ROI images to file
    filename = sprintf('./%s/%s', folder_metal_roi, files_img_raw{n});
    MgSaveRawFile(filename, img_metal_roi);
    
end



%=========================================================================================
% Step 2: forward project metal ROI images
%=========================================================================================
folder_sgm_metal = sprintf('./%s/sgm_metal', folder_temp);
MgMkdir(folder_sgm_metal, true);
js_fpj.InputDir = folder_metal_roi;
js_fpj.OutputDir = folder_sgm_metal;
js_fpj.InputFiles = '.*';
if isfield(js_fpj, 'WaterMu')
    js_fpj_metal_roi = rmfield(js_fpj, 'WaterMu');
end
MgSaveToJsonFile(js_fpj_metal_roi, 'config_fpj_metal_tmp.jsonc');
!mgfpj config_fpj_metal_tmp.jsonc >NUL
delete('config_fpj_metal_tmp.jsonc');

%=========================================================================================
% Step 3: MAR, interpolate sinogram metal region without normalization
%=========================================================================================
folder_sgm_mar = sprintf('./%s/sgm_mar', folder_temp);
MgMkdir(folder_sgm_mar, true);

files_sgm = MgDirRegExp(js_fbp.InputDir, js_fbp.InputFiles);
files_metal = MgDirRegExp(folder_sgm_metal, '.*');

rows = js_fbp.SinogramHeight;
views = js_fbp.Views;
cols = js_fbp.SinogramWidth;
pages = js_fbp.SliceCount;


for n = 1:numel(files_sgm)
    %-------------------------------------
    % read sinograms
    %-------------------------------------
    % initial sinogram
    sgm_raw = MgReadRawFile(sprintf('./%s/%s', js_fbp.InputDir, files_sgm{n}), rows, cols, pages);
    sgm = sgm_raw(1:views, :, :);
    % metal ROI sinogram
    sgm_metal = MgReadRawFile(sprintf('./%s/%s', folder_sgm_metal, files_metal{n}), views, cols, pages);
    
    idx_metal = sgm_metal>small_number;
    sgm_corr = MgInterpSinogramMetal1D(sgm, idx_metal);
    
     % check whether to perform Gaussian smooth
    if isfield(js, "GaussianSmoothSigma")
        sgm_corr = imgaussfilt(sgm_corr, js.GaussianSmoothSigma);
    end
    
    % TODL: sgm = sgm_corr?
    sgm(idx_metal) = sgm_corr(idx_metal);
    sgm_raw(1:views, :, :) = sgm(:, :, :);
    
    % save to file
    filename = sprintf('./%s/%s', folder_sgm_mar, files_sgm{n});
    MgSaveRawFile(filename, sgm_raw);
end

%=========================================================================================
% Step 4: reconstruct images from sinogram with MAR
%=========================================================================================
% reconstruct interpolated images
folder_img_mar = sprintf('./%s/img_mar', folder_temp);
MgMkdir(folder_img_mar, true);

js_fbp.InputDir = folder_sgm_mar;
js_fbp.OutputDir = folder_img_mar;

MgSaveToJsonFile(js_fbp, 'config_fbp_mar_tmp.jsonc');
!mgfbp config_fbp_mar_tmp.jsonc >NUL
delete('config_fbp_mar_tmp.jsonc');

%=========================================================================================
% Step 5: generate prior images from images with MAR
%=========================================================================================
files_img_mar = MgDirRegExp(folder_img_mar, '.*');
files_img_raw = MgDirRegExp(folder_img_raw, '.*');
folder_img_prior = sprintf('./%s/img_prior', folder_temp);
MgMkdir(folder_img_prior, true);
for n = 1:numel(files_img_mar)
    filename = sprintf('./%s/%s', js_fbp.OutputDir, files_img_mar{n});
    img_mar = MgReadRawFile(filename, js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    filename = sprintf('./%s/%s', folder_img_raw, files_img_raw{n});
    img_raw = MgReadRawFile(filename, js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    
    
    % check whether want to circular crop FOV of images
    if isfield(js, 'CircularCropFOVRadius')
        fillValue = 0;
        if isfield(js_fbp, 'WaterMu')
            fillValue = -1000;
        end
        img_mar = MgCropCircleFOV(img_mar, js.CircularCropFOVRadius, fillValue);
    end
    
    % generate img prior
    img_prior = img_raw;
    
    for m = 1:numel(js.AverageRange)-1
        idx_water = img_mar>=js.AverageRange(m) & img_mar<js.AverageRange(m+1);
        img_prior(idx_water) = mean(img_mar(idx_water), 'all');
    end
    
    % save prior images to file
    filename = sprintf('./%s/%s', folder_img_prior, files_img_mar{n});
    MgSaveRawFile(filename, img_prior);
    
end

%=========================================================================================
% Step 6: forward project prior images
%=========================================================================================
folder_sgm_prior = sprintf('./%s/sgm_prior', folder_temp);
MgMkdir(folder_sgm_prior, true);

js_fpj.InputDir = folder_img_prior;
js_fpj.OutputDir = folder_sgm_prior;
js_fpj.InputFiles = '.*';
MgSaveToJsonFile(js_fpj, 'config_fpj_prior_tmp.jsonc');
!mgfpj config_fpj_prior_tmp.jsonc >NUL
delete('config_fpj_prior_tmp.jsonc');

%=========================================================================================
% Step 7: NMAR, interpolate sinogram metal region with normalization
%=========================================================================================
folder_sgm_nmar = sprintf('./%s/sgm_nmar', folder_temp);
MgMkdir(folder_sgm_nmar, true);

files_sgm = MgDirRegExp(js_fbp.InputDir, js_fbp.InputFiles);
files_metal = MgDirRegExp(folder_sgm_metal, '.*');
files_prior = MgDirRegExp(folder_sgm_prior, '.*');

for n = 1:numel(files_sgm)
    %-------------------------------------
    % read sinograms
    %-------------------------------------
    % initial sinogram
    sgm_raw = MgReadRawFile(sprintf('./%s/%s', js_fbp.InputDir, files_sgm{n}), rows, cols, pages);
    sgm = sgm_raw(1:views, :, :);
    % metal ROI sinogram
    sgm_metal = MgReadRawFile(sprintf('./%s/%s', folder_sgm_metal, files_metal{n}), views, cols, pages);
    % prior sinogram
    sgm_prior = MgReadRawFile(sprintf('./%s/%s', folder_sgm_prior, files_prior{n}), views, cols, pages);

    idx_metal = sgm_metal>small_number;
    sgm_corr = MgInterpSinogramMetal1D(sgm, idx_metal, sgm_prior);
    
     % check whether to perform Gaussian smooth
    if isfield(js, "GaussianSmoothSigma")
        sgm_corr = imgaussfilt(sgm_corr, js.GaussianSmoothSigma);
    end
    
    % TODL: sgm = sgm_corr?
    sgm(idx_metal) = sgm_corr(idx_metal);
    sgm_raw(1:views, :, :) = sgm(:, :, :);
    
    % save to file
    filename = sprintf('./%s/%s', folder_sgm_nmar, files_sgm{n});
    MgSaveRawFile(filename, sgm_raw);
end

%=========================================================================================
% Step 8: reconstruct sinogram with NMAR
%=========================================================================================
% reconstruct interpolated images
folder_img_nmar = sprintf('./%s/img_nmar', folder_temp);
MgMkdir(folder_img_nmar, true);

js_fbp.InputDir = folder_sgm_nmar;
js_fbp.OutputDir = folder_img_nmar;

MgSaveToJsonFile(js_fbp, 'config_fbp_nmar_tmp.jsonc');
!mgfbp config_fbp_nmar_tmp.jsonc >NUL
delete('config_fbp_nmar_tmp.jsonc');

%=========================================================================================
% Step 9: place metal back into image
%=========================================================================================
% insert metal back into images
files_img_nmar = MgDirRegExp(folder_img_nmar, '.*');
files_img_metal_roi = MgDirRegExp(folder_metal_roi, '.*');
files_img_raw = MgDirRegExp(folder_img_raw, '.*');

MgMkdir(js.OutputDir, false);
for n = 1:numel(files_img_nmar)
    img_metal = MgReadRawFile(sprintf('./%s/%s', folder_metal_roi, files_img_metal_roi{n}), js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    img_raw = MgReadRawFile(sprintf('./%s/%s', folder_img_raw, files_img_raw{n}),  js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    img_nmar = MgReadRawFile(sprintf('./%s/%s', folder_img_nmar, files_img_nmar{n}),  js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    
    idx_metal = img_metal > 0.1;
    
    img_nmar(idx_metal) = img_raw(idx_metal);
    
    % make a blur border
    disk = MgDiskMatrix(3);
    idx_large = imdilate(idx_metal, disk);
    img_corr_blur = imgaussfilt(img_nmar, 1);
    img_nmar(idx_large) = img_corr_blur(idx_large);
    
    % check whether want to circular crop FOV of images
    if isfield(js, 'CircularCropFOVRadius')
        fillValue = 0;
        if isfield(js_fbp, 'WaterMu')
            fillValue = -1000;
        end
        img_nmar = MgCropCircleFOV(img_nmar, js.CircularCropFOVRadius, fillValue);
    end
    
    % save to file
    filename = sprintf('./%s/%s', js.OutputDir, files_img_raw{n});
    MgSaveRawFile(filename, img_nmar);
end

%==========================================================================================

if js.KeepTemporaryFile == false
    rmdir(folder_temp, 's');
end



end

