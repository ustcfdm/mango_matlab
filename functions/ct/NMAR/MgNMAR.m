function MgNMAR(config_NMAR_filename)
% MgNMAR(config_NMAR_filename)
% This function is to correct metal artifacts for CT images using NMAR
% (Normalized Metal Artifacts Reduction) method.
% config_NMAR_filename: file name of NMAR config file.

js = MgReadJsoncFile(config_NMAR_filename);
js_fbp = MgReadJsoncFile(js.fbp_config);
js_fpj = MgReadJsoncFile(js.fpj_config);
% folder for saving temporary files
% folder_temp = sprintf('_NMAR_TEMP_%s', datestr(datetime, 30));
folder_temp = sprintf('_NMAR_TEMP_%s', date);
MgMkdir(folder_temp, true);
%=========================================================================================
% Step 1: reconstruct images to get prior images and circular crop images (if required).
%=========================================================================================
% reconstruct images
MgMkdir(js_fbp.OutputDir, true);
system(sprintf('mgfbp %s >NUL', js.fbp_config));
% generate prior images
files = MgDirRegExp(js_fbp.OutputDir, '.*');
folder_prior_img = sprintf('./%s/img_prior', folder_temp);
MgMkdir(folder_prior_img, true);
for n = 1:numel(files)
    filename = sprintf('./%s/%s', js_fbp.OutputDir, files{n});
    img = MgReadRawFile(filename, js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    
    % check whether want to circular crop FOV of images
    if isfield(js, 'CircularCropFOVRadius')
        fillValue = 0;
        if isfield(js_fbp, 'WaterMu')
            fillValue = -1000;
        end
        img = MgCropCircleFOV(img, js.CircularCropFOVRadius, fillValue);
    end
    
    % generate img prior
    img_prior = img;
    idx_water = img>=js.WaterRange(1) & img<js.WaterRange(2);
    img_prior(idx_water) = mean(img(idx_water), 'all');
    
    % save prior images to file
    filename = sprintf('./%s/%s', folder_prior_img, files{n});
    MgSaveRawFile(filename, img_prior);
    
end

%=========================================================================================
% Step 2: forward project prior images and metal ROI images
%=========================================================================================
% switch OutputFileReplace order
str_rep = js_fbp.OutputFileReplace;
for n = 1:2:numel(str_rep)
    tmp = str_rep{n};
    str_rep{n} = str_rep{n+1};
    str_rep{n+1} = tmp;
end
%-------------------------------------
% fpj prior images
%-------------------------------------
folder_prior_sgm = sprintf('./%s/sgm_prior', folder_temp);
MgMkdir(folder_prior_sgm, true);

js_fpj.OutputFileReplace = str_rep;
js_fpj.InputDir = folder_prior_img;
js_fpj.OutputDir = folder_prior_sgm;
js_fpj.InputFiles = '.*';
MgSaveToJsonFile(js_fpj, 'config_fpj_prior.jsonc');
!mgfpj config_fpj_prior.jsonc >NUL
delete('config_fpj_prior.jsonc');

%-------------------------------------
% fpj metal ROI images
%-------------------------------------
folder_metal_sgm = sprintf('./%s/sgm_metal', folder_temp);
MgMkdir(folder_metal_sgm, true);
js_fpj.InputDir = js.MetalRoiDir;
js_fpj.OutputDir = folder_metal_sgm;
js_fpj.InputFiles = js.MetalRoiFiles;
files_tmp = MgDirRegExp(js_fpj.InputDir, js_fpj.InputFiles);
file_tmp = files_tmp{1};
if isfield(js_fpj, 'WaterMu')
    js_fpj = rmfield(js_fpj, 'WaterMu');
end
for n = 1:2:numel(str_rep)
    if contains(file_tmp, str_rep)
        js_fpj.OutputFileReplace(n) = str_rep(n);
        js_fpj.OutputFileReplace(n+1) = str_rep(n+1);
    end
end
MgSaveToJsonFile(js_fpj, 'config_fpj_metal.jsonc');
!mgfpj config_fpj_metal.jsonc >NUL
delete('config_fpj_metal.jsonc');

%=========================================================================================
% Step 3: Interpolate metal region in sinogram
%=========================================================================================
folder_sgm_interp = sprintf('./%s/sgm_interp', folder_temp);
MgMkdir(folder_sgm_interp, true);

files_sgm = MgDirRegExp(js_fbp.InputDir, js_fbp.InputFiles);
files_metal = MgDirRegExp(folder_metal_sgm, '.*');
files_prior = MgDirRegExp(folder_prior_sgm, '.*');

rows = js_fbp.SinogramHeight;
views = js_fbp.Views;
cols = js_fbp.SinogramWidth;
pages = js_fbp.SliceCount;
% 
for n = 1:numel(files_sgm)
    %-------------------------------------
    % read sinograms
    %-------------------------------------
    % initial sinogram
    sgm_raw = MgReadRawFile(sprintf('./%s/%s', js_fbp.InputDir, files_sgm{n}), rows, cols, pages);
    sgm = sgm_raw(1:views, :, :);
    % metal ROI sinogram
    sgm_metal = MgReadRawFile(sprintf('./%s/%s', folder_metal_sgm, files_metal{n}), views, cols, pages);
    % prior sinogram
    sgm_prior = MgReadRawFile(sprintf('./%s/%s', folder_prior_sgm, files_prior{n}), views, cols, pages);
    
    %-------------------------------------
    % normalize sinogram
    %-------------------------------------
    sgm_norm = sgm ./ sgm_prior;
    sgm_norm(isnan(sgm_norm)) = 0;
    sgm_norm(isinf(sgm_norm)) = 0;
    % do the interpolation
    for page = 1:pages
        for row = 1:views
            idx_metal = find(sgm_metal(row,:,page) > 0.01);
            idx_left = min(idx_metal) - 1;
            idx_right = max(idx_metal) + 1;
            
            sgm_norm(row, idx_metal, page) = interp1([idx_left, idx_right], [sgm_norm(row,idx_left,page), sgm_norm(row,idx_right,page)], idx_metal);
        end
    end
    
    sgm_corr = sgm_norm .* sgm_prior;
    
    % check whether to perform Gaussian smooth
    if isfield(js, "GaussianSmoothSigma")
        sgm_corr = imgaussfilt(sgm_corr, js.GaussianSmoothSigma);
    end
    
    idx = sgm_metal > 0.01;
    sgm(idx) = sgm_corr(idx);
    sgm_raw(1:views, :, :) = sgm(:, :, :);
    
    % save to file
    filename = sprintf('./%s/%s', folder_sgm_interp, files_sgm{n});
    MgSaveRawFile(filename, sgm_raw);
end

%=========================================================================================
% Step 4: do the reconstruction and place metal back into image
%=========================================================================================
% reconstruct interpolated images
folder_img_interp = sprintf('./%s/img_interp', folder_temp);
MgMkdir(folder_img_interp, true);

js_fbp.InputDir = folder_sgm_interp;
js_fbp.OutputDir = folder_img_interp;

MgSaveToJsonFile(js_fbp, 'config_fbp_interp.jsonc');
!mgfbp config_fbp_interp.jsonc >NUL
delete('config_fbp_interp.jsonc');

% insert metal back into images
files_img = MgDirRegExp(folder_prior_img, '.*');
files_metal = MgDirRegExp(js.MetalRoiDir, js.MetalRoiFiles);
files_corr = MgDirRegExp(folder_img_interp, '.*');

MgMkdir(js.OutputDir, false);
js_fbp = MgReadJsoncFile(js.fbp_config);
for n = 1:numel(files_img)
    
    img_metal = MgReadRawFile(sprintf('./%s/%s', js.MetalRoiDir, files_metal{n}), js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    img_raw = MgReadRawFile(sprintf('./%s/%s', js_fbp.OutputDir, files_img{n}),  js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    img_corr = MgReadRawFile(sprintf('./%s/%s', folder_img_interp, files_corr{n}),  js_fbp.ImageDimension, js_fbp.ImageDimension, js_fbp.SliceCount);
    
    idx = img_metal > 0.1;
    img_corr(idx) = img_raw(idx);
    
    % check whether want to circular crop FOV of images
    if isfield(js, 'CircularCropFOVRadius')
        fillValue = 0;
        if isfield(js_fbp, 'WaterMu')
            fillValue = -1000;
        end
        img_corr = MgCropCircleFOV(img_corr, js.CircularCropFOVRadius, fillValue);
    end
        
    % save to file
    filename = sprintf('./%s/%s', js.OutputDir, files_corr{n});
    MgSaveRawFile(filename, img_corr);
end

%==========================================================================================

if js.KeepTemporaryFile == false
    rmdir(folder_temp, 's');
end


end
