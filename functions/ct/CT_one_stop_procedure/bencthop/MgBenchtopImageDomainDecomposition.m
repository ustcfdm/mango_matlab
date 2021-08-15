function [folder_out_1, folder_out_2] = MgBenchtopImageDomainDecomposition(config_filename, obj_folder, decomp_recipe, basis_1, basis_2)
% Perform image domain material decomposition from LE and HE images.
% basis_1, basis_2: name of decomposed basis
% decomp_recipe: decomposition recipe in config "MaterialDecompMuMatrix"

js = MgReadJsoncFile(config_filename);


folder_LE = sprintf('./img/%s/LE/%s', js.ObjectName, obj_folder);
folder_HE = sprintf('./img/%s/HE/%s', js.ObjectName, obj_folder);
files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);

% output folder
folder_out_1 = sprintf('./img/%s/image_domain_decomp/%s_%s', js.ObjectName, basis_1, obj_folder);
folder_out_2 = sprintf('./img/%s/image_domain_decomp/%s_%s', js.ObjectName, basis_2, obj_folder);
MgMkdir(folder_out_1, false);
MgMkdir(folder_out_2, false);

[files_LE_short, files_LE_long] = MgDirRegExpV2(folder_LE, files);
[files_HE_short, files_HE_long] = MgDirRegExpV2(folder_HE, files);

for n = 1:numel(files_LE_short)
    img_LE = MgReadRawFile(files_LE_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    img_HE = MgReadRawFile(files_HE_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    % decomposition
    [img_decomp_1, img_decomp_2] = MgMaterialDecomposition(js.MaterialDecompMuMatrix.(decomp_recipe), img_LE, img_HE);
    
    filename = strrep(files_LE_short{n}, '_LE', '');
    file_1 = sprintf('%s/%s', folder_out_1, filename);
    MgSaveRawFile(file_1, img_decomp_1);
    file_2 = sprintf('%s/%s', folder_out_2, filename);
    MgSaveRawFile(file_2, img_decomp_2);
end

end

