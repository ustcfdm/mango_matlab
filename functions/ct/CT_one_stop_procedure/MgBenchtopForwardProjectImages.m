function folder_sgm = MgBenchtopForwardProjectImages(config_filename, obj_folder, delete_tmp_config_file)
% Generate config file for mgfpj and perform forward projection.

if nargin < 3
    delete_tmp_config_file = false;
end

js = MgReadJsoncFile(config_filename);

%============================================================
% config parameters (folder name, geometry etc.)
%============================================================
fpj.InputDir = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
fpj.OutputDir = sprintf('./sgm/%s/%s', js.ObjectName, obj_folder);
MgMkdir(fpj.OutputDir, false);

fpj.InputFiles = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);
fpj.OutputFilePrefix = '';
fpj.OutputFileReplace = {'img_', 'sgm_', sprintf('%d-%d-%d', js.ImageDimension, js.ImageDimension, js.SliceCount), sprintf('%d-%d-%d', js.EviWidth/js.RebinSize, js.Views, js.SliceCount)};

fpj.ImageDimension = js.ImageDimension;
fpj.ImageSize = js.ImageSize;
fpj.SliceCount = js.SliceCount;

fpj.SourceIsocenterDistance = js.SourceIsocenterDistance;
fpj.SourceDetectorDistance = js.SourceDetectorDistance;

fpj.StartAngle = js.ImageRotation;
fpj.DetectorElementCount = js.EviWidth/js.RebinSize;
fpj.Views = js.Views;

fpj.DetectorElementSize = 0.1 * js.RebinSize;
fpj.DetectorOffcenter = js.DetectorOffcenter;

%=================================================================
% forward project images
%=================================================================
% tmp folder for config file
folder_config = 'config_temp';
MgMkdir(folder_config, false);

MgSaveToJsonFile(fpj, 'config_temp/config_fpj.jsonc');
!mgfpj config_temp/config_fpj.jsonc

if delete_tmp_config_file
    delete('./config_temp/config_fbp_tmp.jsonc');
end

folder_sgm = fpj.OutputDir;

end

