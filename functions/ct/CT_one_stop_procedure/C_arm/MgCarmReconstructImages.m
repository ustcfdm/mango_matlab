function folder_img = MgCarmReconstructImages(config_filename, obj_folder, delete_tmp_config_file)
% Generate config file for mgfbp and perform the reconstruction.

if nargin < 3
    delete_tmp_config_file = false;
end

js = MgReadJsoncFile(config_filename);

%============================================================
% config parameters (folder name, geometry etc.)
%============================================================
fbp.InputDir = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder);
fbp.OutputDir = sprintf('./img/%s/%s/', js.ObjectName, obj_folder);
MgMkdir(fbp.OutputDir, false);

fbp.InputFiles = sprintf('sgm_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.EviWidth / js.RebinSize, js.Views, js.SliceCount);
fbp.OutputFilePrefix = '';
fbp.OutputFileReplace = {'sgm_', 'img_', sprintf('%d-%d', js.EviWidth / js.RebinSize, js.Views), sprintf('%d-%d', js.ImageDimension, js.ImageDimension)};
fbp.SaveFilteredSinogram = false;

fbp.SinogramWidth = js.EviWidth / js.RebinSize;
fbp.SinogramHeight = js.Views;
fbp.Views = js.Views;
fbp.SliceCount = js.SliceCount;

fbp.DetectorElementSize = 0.1 * js.RebinSize;
fbp.DetectorOffcenter = js.DetectorOffcenter;
fbp.SourceIsocenterDistance = js.SourceIsocenterDistance;
fbp.SourceDetectorDistance = js.SourceDetectorDistance;

fbp.ImageSize = js.ImageSize;
fbp.ImageDimension = js.ImageDimension;
fbp.ImageRotation = js.ImageRotation;
fbp.ImageCenter = js.ImageCenter;

fbp.(js.KernelName) = js.KernelParameter;

%------------------------------------------
% pmatrix information
%------------------------------------------
fbp.PMatrixFile = sprintf('%s/pmatrix_file.jsonc', js.PmatrixFolder);
fbp.SDDFile = sprintf('%s/sdd_file.jsonc', js.PmatrixFolder);
fbp.SIDFile = sprintf('%s/sid_file.jsonc', js.PmatrixFolder);
fbp.DetectorOffCenterFile = sprintf('%s/offcenter_file.jsonc', js.PmatrixFolder);
fbp.ScanAngleFile = sprintf('%s/scan_angle.jsonc', js.PmatrixFolder);

%=================================================================
% reconstruct images
%=================================================================
% tmp folder for config file
folder_config = 'config_temp';
MgMkdir(folder_config, false);

MgSaveToJsonFile(fbp, './config_temp/config_fbp_tmp.jsonc');
!mgfbp ./config_temp/config_fbp_tmp.jsonc

if delete_tmp_config_file
    delete('./config_temp/config_fbp_tmp.jsonc');
end

folder_img = fbp.OutputDir;

end

