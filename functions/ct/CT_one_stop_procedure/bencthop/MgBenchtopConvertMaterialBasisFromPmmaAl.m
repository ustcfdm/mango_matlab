function [outputArg1,outputArg2] = MgBenchtopConvertMaterialBasisFromPmmaAl(config_filename, obj_PMMA_folder, obj_Al_folder, outputBasis)
% Convert PMMA + Al basis to another basis images.
% outputBasis: (string) available options are
%              water_iodine, water_calcium
js = MgReadJsoncFile(config_filename);

if outputBasis == "water_iodine"
    Mu = [1.1521, 2.1553; -0.0003, 0.0088];
    obj_out_1 = strrep(obj_PMMA_folder, 'PMMA_decomp', 'decomp_water(iodine)');
    obj_out_2 = strrep(obj_Al_folder, 'Al_decomp', 'decomp_iodine(water)');
    % material density
    den1 = MgGetMaterialDensity('water');
    den2 = MgGetMaterialDensity('I')*1000;
elseif outputBasis == "water_calcium"
    Mu = [1.1630, 1.8295; -0.0122, 0.3684];
    obj_out_1 = strrep(obj_PMMA_folder, 'PMMA_decomp', 'decomp_water(calcium)');
    obj_out_2 = strrep(obj_Al_folder, 'Al_decomp', 'decomp_calcium(water)');
    % material density
    den1 = MgGetMaterialDensity('water');
    den2 = MgGetMaterialDensity('Ca')*1000;
end

folder_PMMA = sprintf('./img/%s/%s', js.ObjectName, obj_PMMA_folder);
folder_Al = sprintf('./img/%s/%s', js.ObjectName, obj_Al_folder);
files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);

% output folder
folder_out_1 = sprintf('./img/%s/%s', js.ObjectName, obj_out_1);
folder_out_2 = sprintf('./img/%s/%s', js.ObjectName, obj_out_2);
MgMkdir(folder_out_1, false);
MgMkdir(folder_out_2, false);

[files_PMMA_short, files_PMMA_long] = MgDirRegExpV2(folder_PMMA, files);
[files_Al_short, files_Al_long] = MgDirRegExpV2(folder_Al, files);

for n = 1:numel(files_PMMA_short)
    img_PMMA = MgReadRawFile(files_PMMA_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    img_Al = MgReadRawFile(files_Al_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    [img1, img2] = MgMaterialForwardComposition(Mu, img_PMMA, img_Al);
    
    % save to file
    filename = sprintf('%s/%s', folder_out_1, files_PMMA_short{n});
    MgSaveRawFile(filename, img1);
    filename = sprintf('%s/%s', folder_out_2, files_PMMA_short{n});
    MgSaveRawFile(filename, img2*den2);
end


end

