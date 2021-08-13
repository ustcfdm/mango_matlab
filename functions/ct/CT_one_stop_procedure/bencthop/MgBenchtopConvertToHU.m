function folder_img_HU = MgBenchtopConvertToHU(config_filename, obj_folder, useRelativeMu)
% convert images to HU unit.
% useRelativeMu: true (default) if the unit is mu/mu_PMMA; false if the unit is mu (mm-1)

js = MgReadJsoncFile(config_filename);

if nargin < 3
    mu_water = js.MuWater;
elseif useRelativeMu
    mu_water = js.MuWater;
else
    mu_water = js.MuWater * js.MuPmma;
end


folder_img_mu = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
folder_img_HU = sprintf('./img/%s/%s_HU', js.ObjectName, obj_folder);
MgMkdir(folder_img_HU, false);

files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);

[files_short, files_long] = MgDirRegExpV2(folder_img_mu, files);

for n = 1:numel(files_short)
    img = MgReadRawFile(files_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    img_HU = MgConvertMuToHU(img, mu_water);
    
    filename = sprintf('%s/%s', folder_img_HU, files_short{n});
    MgSaveRawFile(filename, img_HU);
end


end

