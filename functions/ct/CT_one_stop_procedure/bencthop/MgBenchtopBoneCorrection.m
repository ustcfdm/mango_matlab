function MgBenchtopBoneCorrection(config_filename, obj_folder, corr_recipe)
% Apply emperical bone correciton for benchtop.
% corr_recipe: the recipe name in "BoneCorr" item.

js = MgReadJsoncFile(config_filename);

%====================================================================
% Parse correction parameters
%====================================================================
% correction coefficients
coeff = [];
% correction terms
terms = [""];

% idx for coefficients and terms
idx = 1;
% parameters string
s = js.BoneCorr.(corr_recipe).CorrFormula;
tmp = "";
coeff(idx) = 1;
for n = 1:strlength(s)
    if isstrprop(s(n), 'digit') || s(n) == "."
        tmp = tmp + s(n);
    elseif s(n) == "w" || s(n) == "b"
        tmp = s(n);
    end
    if s(n) == "*" || s(n) == "+" || s(n) == "-" || n==strlength(s)
        if tmp == "w" || tmp == "b"
            if idx > numel(terms)
                terms(idx) = "";
            end
            terms(idx) = terms(idx) + tmp;
        else
            coeff(idx) = str2num(tmp);
        end
        tmp = "";
        if s(n) == "+" || s(n) == "-"
            idx = idx + 1;
            tmp = convertCharsToStrings(s(n));
        end
    end
end

%====================================================================
% segment images into water and bone parts
%====================================================================
folder_img_no_corr = sprintf('./img/%s/%s', js.ObjectName, obj_folder);
files_img = sprintf('img_%s_%s_%d-%d-%d.raw', js.ObjectIndex, js.EnergyBin, js.ImageDimension, js.ImageDimension, js.SliceCount);
folder_img_b = sprintf('./img/%s/tmp_bc/%s_b', js.ObjectName, obj_folder);
folder_img_w = sprintf('./img/%s/tmp_bc/%s_w', js.ObjectName, obj_folder);
MgMkdir(folder_img_b, false);
MgMkdir(folder_img_w, false);

[files_img_short, files_img_long] = MgDirRegExpV2(folder_img_no_corr, files_img);
for n = 1:numel(files_img_short)
    img = MgReadRawFile(files_img_long{n}, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    % bone part
    img_bone = zeros(size(img));
    idx_bone = img >= js.BoneCorr.(corr_recipe).BoneRange(1) & img < js.BoneCorr.(corr_recipe).BoneRange(2);
    img_bone(idx_bone) = img(idx_bone);
    filename = sprintf('%s/%s', folder_img_b, files_img_short{n});
    MgSaveRawFile(filename, img_bone);
    
    % water part
    img_water = zeros(size(img));
    idx_water = img >= js.BoneCorr.(corr_recipe).WaterRange(1) & img < js.BoneCorr.(corr_recipe).WaterRange(2);
    img_water(idx_water) = img(idx_water);
    filename = sprintf('%s/%s', folder_img_w, files_img_short{n});
    MgSaveRawFile(filename, img_water);
end

%------------------------------------
% forward segmented images
%------------------------------------
folder_sgm_b = MgBenchtopForwardProjectImages(config_filename, sprintf('tmp_bc/%s_b', obj_folder));
folder_sgm_w = MgBenchtopForwardProjectImages(config_filename, sprintf('tmp_bc/%s_w', obj_folder));

%====================================================================
% generate sinogram cross terms
%====================================================================
% generate folders for cross terms
folder_cross_terms_sgm = cell(1, numel(terms));
for idx = 1:numel(terms)
    foldername = sprintf('./sgm/%s/tmp_bc/%s_%s', js.ObjectName, obj_folder, terms{idx});
    MgMkdir(foldername, true);
    folder_cross_terms_sgm{idx} = foldername;
end
files_sgm = sprintf('sgm_%s_%s_%d-%d-%d.raw', js.ObjectIndex, js.EnergyBin, js.EviWidth/js.RebinSize, js.Views, js.SliceCount);
files_sgm_short = MgDirRegExpV2(folder_sgm_b, files_sgm);
% calculate the cross terms
for n = 1:numel(files_img_short)
    filename = sprintf("%s/%s", folder_sgm_b, files_sgm_short{n});
    sgm_bone = MgReadRawFile(filename, js.Views, js.EviWidth/js.RebinSize, js.SliceCount);
    filename = sprintf("%s/%s", folder_sgm_w, files_sgm_short{n});
    sgm_water = MgReadRawFile(filename, js.Views, js.EviWidth/js.RebinSize, js.SliceCount);
    
    % for each cross term
    for idx = 1:numel(terms)
        term = convertStringsToChars(terms(idx));
        % cross term sinogram to be calculated
        sgm = ones(js.Views, js.EviWidth/js.RebinSize, js.SliceCount);
        % do the multiplication
        for t = 1:numel(term)
            if term(t) == 'w'
                sgm = sgm .* sgm_water;
            elseif term(t) == 'b'
                sgm = sgm .* sgm_bone;
            end
        end
        % save to corresponding folder
        filename = sprintf("%s/%s", folder_cross_terms_sgm{idx}, files_sgm_short{n});
        MgSaveRawFile(filename, sgm);
    end
end

%====================================================================
% do the backprojection for cross terms
%====================================================================
folder_img_cs = cell(1, numel(terms));
for n = 1:numel(terms)
    folder_img_cs{n} = MgBenchtopReconstructImages(config_filename, sprintf('tmp_bc/%s_%s', obj_folder, terms{n}));
end

%====================================================================
% sum up each cross terms to get final images
%====================================================================
folder_img_bc = sprintf('./img/%s/%s_bc', js.ObjectName, obj_folder);
MgMkdir(folder_img_bc, false);
for k = 1:numel(files_img_short)
    % read image
    filename = sprintf("%s/%s", folder_img_no_corr, files_img_short{k});
    img = MgReadRawFile(filename, js.ImageDimension, js.ImageDimension, js.SliceCount);
    % add cross terms
    for idx = 1:numel(terms)
        filename = sprintf("%s/%s", folder_img_cs{idx}, files_img_short{k});
        img_tmp = MgReadRawFile(filename, js.ImageDimension, js.ImageDimension, js.SliceCount); 
        img = img + img_tmp * coeff(idx);
    end
    % save to output folder
    filename = sprintf("%s/%s", folder_img_bc, files_img_short{k});
    MgSaveRawFile(filename, img);
end



end














