function folder_img_rc = MgBenchtopRingCorrection(config_filename, obj_folder, recipe)
% Perform ring correction.
% rc_set: ring correction parameter set.

js = MgReadJsoncFile(config_filename);

folder_img_in = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
folder_img_rc = sprintf('./img/%s/%s_rc', js.ObjectName, obj_folder);
MgMkdir(folder_img_rc, false);

files = sprintf('img_%s_.*%d-%d-%d.raw', js.ObjectIndex, js.ImageDimension, js.ImageDimension, js.SliceCount);

[files_short, files_long] = MgDirRegExpV2(folder_img_in, files);

% ring correction parameters
p = js.RingCorr.(recipe);

for n = 1:numel(files_short)
    img = MgReadRawFile(files_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    img_rc = zeros(size(img));
    for s = 1:size(img, 3)
        img_rc(:,:,s) = MgRingCorrectionSplit(img, p(1),p(2),p(3),p(4),p(5),p(6),p(7),p(8),p(9),p(10),p(11));
    end
    
    
    filename = sprintf('%s/%s', folder_img_rc, files_short{n});
    MgSaveRawFile(filename, img_rc);
end


end

