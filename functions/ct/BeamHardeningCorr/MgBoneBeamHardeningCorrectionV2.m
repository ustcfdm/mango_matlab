function MgBoneBeamHardeningCorrectionV3(config_filename)
% MgBoneBeamHardeningCorrection(config_filename)
% Perform beam beam hardening correction for ct images. All configurations
% are in config file.
% To get a sample config file, use function
% MgGetBoneCorrectionConfigSampleFile
% config_filename: config file name.

% read config file
js = MgReadJsoncFile(config_filename);
jsfbp = MgReadJsoncFile(js.FbpConfigFile);
jsfpj = MgReadJsoncFile(js.FpjConfigFile);

% temporary folder for intermediate files
tmp_folder = '_BONE_CORR_TEMP_FOLDER_';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% acquire all input file names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder = js.InputDir;
inputFiles = {};
idx = 1;
f = dir(folder);
for k = 1:numel(f)
    startIdx = regexp(f(k).name, js.InputFiles, 'once', 'start');
    endIdx = regexp(f(k).name, js.InputFiles, 'once', 'end');
    if startIdx == 1 & endIdx == numel(f(k).name)
        inputFiles{idx} = f(k).name;
        idx = idx + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate all final output file names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputFiles = cell(size(inputFiles));
for k = 1:numel(inputFiles)
    tmp = inputFiles{k};
    for idx = 1:2:numel(js.OutputFileReplace)
        tmp = strrep(tmp, js.OutputFileReplace(idx), js.OutputFileReplace(idx+1));
    end
    outputFiles{k} = sprintf("%s%s", js.OutputFilePrefix, tmp{1} );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse correction parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% correction coefficients
coeff = [];
% correction terms
terms = [""];

% idx for coefficients and terms
idx = 1;
% parameters string
s = js.CorrectionParameters;
tmp = "";
coeff(idx) = 1;
for k = 1:strlength(s)
    if s(k) == " "
        continue;
    elseif isstrprop(s(k), 'digit') || s(k) == "."
        tmp = tmp + s(k);
    elseif s(k) == "w" || s(k) == "b"
        tmp = s(k);
    end
    if s(k) == "*" || s(k) == "+" || s(k) == "-" || k==strlength(s)
        if tmp == "w" || tmp == "b"
            if idx > numel(terms)
                terms(idx) = "";
            end
            terms(idx) = terms(idx) + tmp;
        else
            coeff(idx) = str2num(tmp);
        end
        tmp = "";
        if s(k) == "+" || s(k) == "-"
            idx = idx + 1;
            tmp = convertCharsToStrings(s(k));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% segment images into water and bone parts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_img_b = sprintf('./%s/img_b', tmp_folder);
MgMkdir(folder_img_b, true);
folder_img_w = sprintf('./%s/img_w', tmp_folder);
MgMkdir(folder_img_w, true);


for k = 1:numel(inputFiles)
    % read image
    filename = sprintf("%s/%s", folder, inputFiles{k});
    img = MgReadRawFile(filename, jsfbp.ImageDimension, jsfbp.ImageDimension, jsfbp.SliceCount);
    
    % segment
    % bone part
    img_bone = zeros(size(img));
    idx_bone = img >= js.BoneRange(1) & img <= js.BoneRange(2);
    img_bone(idx_bone) = img(idx_bone);
    filename = sprintf("%s/%s", folder_img_b, inputFiles{k});
    MgSaveRawFile(filename, img_bone);
    % water part
    img_water = zeros(size(img));
    idx_water = img >= js.WaterRange(1) & img < js.WaterRange(2);
    img_water(idx_water) = img(idx_water);
    filename = sprintf("%s/%s", folder_img_w, inputFiles{k});
    MgSaveRawFile(filename, img_water);
end

% generate config file and do forward projection
folder_sgm_b = sprintf('./%s/sgm_b', tmp_folder);
MgMkdir(folder_sgm_b, true);
folder_sgm_w = sprintf('./%s/sgm_w', tmp_folder);
MgMkdir(folder_sgm_w, true);


% for water part
jsfpj.InputDir = folder_img_w;
jsfpj.OutputDir = folder_sgm_w;
jsfpj.InputFiles = ".*";
jsfpj.OutputFilePrefix = "";
jsfpj.OutputFileReplace = [];

MgSaveToJsonFile(jsfpj, sprintf('./%s/tmp_config_fpj_w.jsonc', tmp_folder))
system(sprintf('mgfpj ./%s/tmp_config_fpj_w.jsonc >NUL', tmp_folder));
% for bone part
jsfpj.InputDir = folder_img_b;
jsfpj.OutputDir = folder_sgm_b;
jsfpj.InputFiles = ".*";
jsfpj.OutputFilePrefix = "";
jsfpj.OutputFileReplace = [];

MgSaveToJsonFile(jsfpj, sprintf('./%s/tmp_config_fpj_b.jsonc', tmp_folder))
system(sprintf('mgfpj ./%s/tmp_config_fpj_b.jsonc >NUL', tmp_folder));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate sinogram cross terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate folders for cross terms
folder_cross_terms_sgm = {};
for idx = 1:numel(terms)
    foldername = sprintf('./%s/sgm_%s', tmp_folder, terms{idx});
    MgMkdir(foldername, true);
    folder_cross_terms_sgm{idx} = foldername;
end
% calculate the cross terms
for k = 1:numel(inputFiles)
    filename = sprintf("%s/%s", folder_sgm_b, inputFiles{k});
    sgm_bone = MgReadRawFile(filename, jsfpj.Views, jsfpj.DetectorElementCount, jsfpj.SliceCount);
    filename = sprintf("%s/%s", folder_sgm_w, inputFiles{k});
    sgm_water = MgReadRawFile(filename, jsfpj.Views, jsfpj.DetectorElementCount, jsfpj.SliceCount);
    
    % for each cross term
    for idx = 1:numel(terms)
        term = convertStringsToChars(terms(idx));
        % cross term sinogram to be calculated
        sgm = ones(jsfpj.Views, jsfpj.DetectorElementCount, jsfpj.SliceCount);
        % do the multiplication
        for t = 1:numel(term)
            if term(t) == 'w'
                sgm = sgm .* sgm_water;
            elseif term(t) == 'b'
                sgm = sgm .* sgm_bone;
            end
        end
        % save to corresponding folder
        filename = sprintf("%s/%s", folder_cross_terms_sgm{idx}, inputFiles{k});
        MgSaveRawFile(filename, sgm);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% do the backprojection for cross terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jsfbp.InputFiles = ".*";
jsfbp.OutputFilePrefix = "";
jsfbp.OutputFileReplace = [];
jsfbp.SaveFilteredSinogram = false;

% generate folders for cross terms in image domain
folder_cross_terms_img = {};
for idx = 1:numel(terms)
    foldername = sprintf('./%s/img_%s', tmp_folder, terms{idx});
    MgMkdir(foldername, true);
    folder_cross_terms_img{idx} = foldername;
end

% for each cross terms
for idx = 1:numel(terms)
    jsfbp.InputDir = folder_cross_terms_sgm{idx};
    jsfbp.OutputDir = folder_cross_terms_img{idx};
    
    filename = sprintf('./%s/tmp_config_fbp_%s.jsonc', tmp_folder, terms{idx});
    MgSaveToJsonFile(jsfbp, filename);
    
    % do the backprojection
    system(sprintf("mgfbp %s >NUL", filename));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sum up each cross terms to get final images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:numel(inputFiles)
    % read image
    filename = sprintf("%s/%s", folder, inputFiles{k});
    img = MgReadRawFile(filename, jsfbp.ImageDimension, jsfbp.ImageDimension, jsfbp.SliceCount); 
    % add cross terms
    for idx = 1:numel(terms)
        filename = sprintf("%s/%s", folder_cross_terms_img{idx}, inputFiles{k});
        img_tmp = MgReadRawFile(filename, jsfbp.ImageDimension, jsfbp.ImageDimension, jsfbp.SliceCount); 
        img = img + img_tmp * coeff(idx);
    end
    % save to output folder
    MgMkdir(js.OutputDir, true);
    filename = sprintf("%s/%s", js.OutputDir, outputFiles{k});
    MgSaveRawFile(filename, img);
end

% decide wheter to delete temporary files
if ~js.KeepTemporaryFiles
    rmdir(tmp_folder, 's');
end



end



