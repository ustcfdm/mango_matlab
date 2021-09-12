function obj_panel_corr = MgBenchtopPanelCorrSeg(config, receipe )
% Apply panel correction use segmentation based method.

js = MgReadJsoncFile(config);
js_panel = js.PanelCorrSeg.(receipe);

% folder of images
obj_folder = sprintf('%s/PMMA_corr', js.EnergyBin);

% regular expression for matching files
files_img = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);
files_sgm = sprintf('sgm_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.EviWidth / js.RebinSize, js.Views, js.SliceCount);

%=====================================================
% Step 1: segment images' bone region
%=====================================================
folder_img = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
folder_img_bone = sprintf('./img/%s/%s_bone', js.ObjectName, obj_folder);
MgMkdir(folder_img_bone, false);

[files_short, files_long] = MgDirRegExpV2(folder_img, files_img);

for n = 1:numel(files_short)
    img = MgReadRawFile(files_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    [~, img_bone] = MgSoftThresholdSegment(img, js_panel.SegThresholds(1), js_panel.SegThresholds(2), true);
    
    % save to file
    MgSaveRawFile(sprintf('%s/%s', folder_img_bone, files_short{n}), img_bone);
end

%=====================================================
% Step 2: forward project bone-only images
%=====================================================
obj_img_bone = sprintf('%s/PMMA_corr_bone', js.EnergyBin);
folder_sgm_bone = MgBenchtopForwardProjectImages(config, obj_img_bone);

%=====================================================
% Step 3: Do the panel correciton
%=====================================================
% load panel correction parameters
filename = sprintf('%s/cali_bone_seg.mat', MgBenchtopGetPanelCorrProtocolFolder(js.PanelCorrProtocol));
cali_PMMA = load(filename, sprintf('cali_PMMA_%s_Li', js.EnergyBin)).(sprintf('cali_PMMA_%s_Li', js.EnergyBin));

% sgm and sgm_bone
folder_sgm_no_corr = sprintf('./sgm/%s/%s/%s', js.ObjectName, js.EnergyBin, 'no_corr');
[files_sgm_short, files_sgm_long] = MgDirRegExpV2(folder_sgm_no_corr, files_sgm);
[files_sgm_bone_short, files_sgm_bone_long] = MgDirRegExpV2(folder_sgm_bone, files_sgm);

folder_sgm_panel_corr = sprintf('./sgm/%s/%s_panel_corr', js.ObjectName, obj_folder);
MgMkdir(folder_sgm_panel_corr);

for n = 1:numel(files_sgm_short)
    sgm = MgReadRawFile(files_sgm_long{n}, js.Views, js.EviWidth/js.RebinSize, js.SliceCount);
    sgm_bone = MgReadRawFile(files_sgm_bone_long{n}, js.Views, js.EviWidth/js.RebinSize, js.SliceCount) * js_panel.PmmaToAlFactor;
    
    MgWriteTiff('sgm.tif', sgm);
    MgWriteTiff('sgm_bone.tif', sgm_bone);
    
    % reslice to projection shape
    prj = MgResliceSinogramToProjection(sgm, js.SliceStartIdx, js.EviHeight, js.RebinSize, js.SliceThickness);
    prj_bone = MgResliceSinogramToProjection(sgm_bone, js.SliceStartIdx, js.EviHeight, js.RebinSize, js.SliceThickness);
    
    % do the panel correction
    prj_pmma = MgPolyvalTwoVariable(cali_PMMA, prj, prj_bone);
    prj_pmma(isnan(prj_pmma)) = 0;
    prj_pmma(isinf(prj_pmma)) = 0;
  
    % combine pmma and bone
    prj_merge = prj_pmma + prj_bone / js_panel.PmmaToAlFactor;
    
    prj_merge = MgBenchtopBadPixelCorr(prj_merge);
    
    % reslice to sinogram
    sgm_merge = MgResliceProjectionToSinogram(prj_merge, js.SliceStartIdx, js.SliceThickness, js.SliceCount);
    
    % interp gap
    sgm_merge = MgInterpSinogram(sgm_merge, 1, 2, 4);
    
    % axial rebin
    sgm_merge = MgRebinSinogram(sgm_merge, js.RebinSize);
    
    % save to file
    filename = sprintf('%s/%s', folder_sgm_panel_corr, files_sgm_short{n});
    MgSaveRawFile(filename, sgm_merge);    
end


%=====================================================
% Step 3: Reconstruct images
%=====================================================
obj_panel_corr = sprintf('%s/PMMA_corr_panel_corr', js.EnergyBin);
MgBenchtopReconstructImages(config, obj_panel_corr);


end

