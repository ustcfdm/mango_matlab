function folder_img_HU = MgCarmConvertToHU(config_filename, obj_folder)
% convert images to HU unit.

js = MgReadJsoncFile(config_filename);

folder_img_mu = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
folder_img_HU = sprintf('./img/%s/%s_HU', js.ObjectName, obj_folder);
MgMkdir(folder_img_HU, false);

files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);

[files_short, files_long] = MgDirRegExpV2(folder_img_mu, files);

for n = 1:numel(files_short)
    img = MgReadRawFile(files_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    img_HU = MgConvertMuToHU(img, js.MuWater);
    
    filename = sprintf('%s/%s', folder_img_HU, files_short{n});
    MgSaveRawFile(filename, img_HU);
end


end

