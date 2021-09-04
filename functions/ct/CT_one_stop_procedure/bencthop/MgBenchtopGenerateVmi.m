function [outputArg1,outputArg2] = MgBenchtopGenerateVmi(config_file)
% Generate virtual monoenergetic images from PMMA and Al basis images.

js = MgReadJsoncFile(config_file);

folder_img_PMMA = sprintf('./img/%s/DE/PMMA_decomp', js.ObjectName);
folder_img_Al = sprintf('./img/%s/DE/Al_decomp', js.ObjectName);


files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);
[files_PMMA_short, files_PMMA_long] = MgDirRegExpV2(folder_img_PMMA, files);
[files_Al_short, files_Al_long] = MgDirRegExpV2(folder_img_Al, files);

for e = 1:numel(js.VmiEnergy)
    folder_vmi = sprintf('./img/%s/DE/VMI_%dkeV', js.ObjectName, js.VmiEnergy(e));
    MgMkdir(folder_vmi, false);
    
    % get mu data
    mu_PMMA = MgGetLinearAttenuation('PMMA',  js.VmiEnergy(e));
    mu_Al = MgGetLinearAttenuation('Al',  js.VmiEnergy(e));
    mu_w = MgGetLinearAttenuation('water',  js.VmiEnergy(e));
    
    for n = 1:numel(files_PMMA_short)
        img_PMMA = MgReadRawFile(files_PMMA_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
        img_Al = MgReadRawFile(files_Al_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
        
        % generate vmi
        img_vmi = mu_PMMA*img_PMMA + mu_Al*img_Al;
        % convert to HU
        img_vmi_HU = MgConvertMuToHU(img_vmi, mu_w);
        
        % save to file
        filename = sprintf('%s/%s', folder_vmi, files_PMMA_short{n});
        MgSaveRawFile(filename, img_vmi_HU);
    end    
end

end

