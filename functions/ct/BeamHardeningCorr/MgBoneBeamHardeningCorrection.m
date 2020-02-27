function MgBoneBeamHardeningCorrection(config_filename)
% MgBoneBeamHardeningCorrection(config_filename)
% Perform beam beam hardening correction for ct images. All configurations
% are in config file.
% To get a sample config file, use function
% MgGetBoneCorrectionConfigSampleFile
% config_filename: config file name.

% read config file
js = MgReadJsoncFile(config_filename);

% temporary files and folders to be deleted
tmp_files = {};
tmp_folders = {};

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
if exist(  "__MG_BONE_CORR_IMG_SEG_BONE_PART__" , 'dir')
    rmdir("__MG_BONE_CORR_IMG_SEG_BONE_PART__", 's')
end
mkdir("__MG_BONE_CORR_IMG_SEG_BONE_PART__")
if exist(  "__MG_BONE_CORR_IMG_SEG_WATER_PART__" , 'dir')
    rmdir("__MG_BONE_CORR_IMG_SEG_WATER_PART__", 's')
end
mkdir("__MG_BONE_CORR_IMG_SEG_WATER_PART__")
tmp_folders{end+1} = "__MG_BONE_CORR_IMG_SEG_BONE_PART__";
tmp_folders{end+1} = "__MG_BONE_CORR_IMG_SEG_WATER_PART__";

for k = 1:numel(inputFiles)
    % read image
    filename = sprintf("%s/%s", folder, inputFiles{k});
    img = MgReadRawFile(filename, js.ImageDimension, js.ImageDimension, js.SliceCount);
    
    % segment
    % bone part
    img_bone = zeros(size(img));
    idx_bone = img >= js.BoneRange(1) & img <= js.BoneRange(2);
    img_bone(idx_bone) = img(idx_bone);
    filename = sprintf("__MG_BONE_CORR_IMG_SEG_BONE_PART__/%s", inputFiles{k});
    MgSaveRawFile(filename, img_bone);
    % water part
    img_water = zeros(size(img));
    idx_water = img >= js.WaterRange(1) & img < js.WaterRange(2);
    img_water(idx_water) = img(idx_water);
    filename = sprintf("__MG_BONE_CORR_IMG_SEG_WATER_PART__/%s", inputFiles{k});
    MgSaveRawFile(filename, img_water);
end

% generate config file and do forward projection
if exist(  "__MG_BONE_CORR_SGM_SEG_BONE_PART__" , 'dir')
    rmdir("__MG_BONE_CORR_SGM_SEG_BONE_PART__", 's')
end
mkdir("__MG_BONE_CORR_SGM_SEG_BONE_PART__")
if exist(  "__MG_BONE_CORR_SGM_SEG_WATER_PART__" , 'dir')
    rmdir("__MG_BONE_CORR_SGM_SEG_WATER_PART__", 's')
end
mkdir("__MG_BONE_CORR_SGM_SEG_WATER_PART__")

tmp_folders{end+1} = "__MG_BONE_CORR_SGM_SEG_BONE_PART__";
tmp_folders{end+1} = "__MG_BONE_CORR_SGM_SEG_WATER_PART__";

js_fpj = js;
% for water part
js_fpj.InputDir = "__MG_BONE_CORR_IMG_SEG_WATER_PART__";
js_fpj.OutputDir = "__MG_BONE_CORR_SGM_SEG_WATER_PART__";
js_fpj.InputFiles = ".*";
js_fpj.OutputFilePrefix = "";
js_fpj.OutputFileReplace = [];
js_fpj.StartAngle = 0;
MgSaveToJsonFile(js_fpj, "__CONFIG_MGFPJ_SEGMENT_WATER_PART__.JSONC")
!mgfpj __CONFIG_MGFPJ_SEGMENT_WATER_PART__.JSONC >NUL
% for bone part
js_fpj.InputDir = "__MG_BONE_CORR_IMG_SEG_BONE_PART__";
js_fpj.OutputDir = "__MG_BONE_CORR_SGM_SEG_BONE_PART__";
js_fpj.InputFiles = ".*";
js_fpj.OutputFilePrefix = "";
js_fpj.OutputFileReplace = [];
js_fpj.StartAngle = 0;
MgSaveToJsonFile(js_fpj, "__CONFIG_MGFPJ_SEGMENT_BONE_PART__.JSONC")
!mgfpj __CONFIG_MGFPJ_SEGMENT_BONE_PART__.JSONC >NUL

tmp_files{end+1} = "__CONFIG_MGFPJ_SEGMENT_WATER_PART__.JSONC";
tmp_files{end+1} = "__CONFIG_MGFPJ_SEGMENT_BONE_PART__.JSONC";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate sinogram cross terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate folders for cross terms
folder_cross_terms_sgm = {};
for idx = 1:numel(terms)
    foldername = sprintf("__MG_BONE_CORR_SGM_SEG_%s_PART__", upper(terms{idx}));
    if exist(foldername, 'dir')
        rmdir(foldername, 's');
    end
    mkdir(foldername);
    folder_cross_terms_sgm{idx} = foldername;
    tmp_folders{end+1} = foldername;
end
% calculate the cross terms
for k = 1:numel(inputFiles)
    filename = sprintf("__MG_BONE_CORR_SGM_SEG_BONE_PART__/%s", inputFiles{k});
    sgm_bone = MgReadRawFile(filename, js.Views, js.DetectorElementCount, js.SliceCount);
    filename = sprintf("__MG_BONE_CORR_SGM_SEG_WATER_PART__/%s", inputFiles{k});
    sgm_water = MgReadRawFile(filename, js.Views, js.DetectorElementCount, js.SliceCount);
    
    % for each cross term
    for idx = 1:numel(terms)
        term = convertStringsToChars(terms(idx));
        % cross term sinogram to be calculated
        sgm = ones(js.Views, js.DetectorElementCount, js.SliceCount);
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
js_fbp = js;

js_fbp.InputFiles = ".*";
js_fbp.OutputFilePrefix = "";
js_fbp.OutputFileReplace = [];
js_fbp.SaveFilteredSinogram = false;
js_fbp.SinogramWidth = js.DetectorElementCount;
js_fbp.SinogramHeight = js.Views;
js_fbp.ImageRotation = 0;
js_fbp.ImageCenter = [0, 0];

% generate folders for cross terms in image domain
folder_cross_terms_img = {};
for idx = 1:numel(terms)
    foldername = sprintf("__MG_BONE_CORR_IMG_SEG_%s_PART__", upper(terms{idx}));
    if exist(foldername, 'dir')
        rmdir(foldername, 's');
    end
    mkdir(foldername);
    folder_cross_terms_img{idx} = foldername;
    tmp_folders{end+1} = foldername;
end

% for each cross terms
for idx = 1:numel(terms)
    js_fbp.InputDir = folder_cross_terms_sgm{idx};
    js_fbp.OutputDir = folder_cross_terms_img{idx};
    
    filename = sprintf("__CONFIG_MGFBP_CROSS_TERM_%s_PART__.JSONC", upper(terms{idx}));
    MgSaveToJsonFile(js_fbp, filename);
    
    tmp_files{end+1} = filename;
    
    % do the backprojection
    system(sprintf("mgfbp %s >NUL", filename));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sum up each cross terms to get final images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:numel(inputFiles)
    % read image
    filename = sprintf("%s/%s", folder, inputFiles{k});
    img = MgReadRawFile(filename, js.ImageDimension, js.ImageDimension, js.SliceCount); 
    % add cross terms
    for idx = 1:numel(terms)
        filename = sprintf("%s/%s", folder_cross_terms_img{idx}, inputFiles{k});
        img_tmp = MgReadRawFile(filename, js.ImageDimension, js.ImageDimension, js.SliceCount); 
        img = img + img_tmp * coeff(idx);
    end
    % save to output folder
    if ~exist(js.OutputDir, 'dir')
        mkdir(js.OutputDir);
    end
    filename = sprintf("%s/%s", js.OutputDir, outputFiles{k});
    MgSaveRawFile(filename, img);
end

% decide wheter to delete temporary files
if ~js.KeepTemporaryFiles
    for idx = 1:numel(tmp_folders)
        rmdir(tmp_folders{idx}, 's');
    end
    for idx = 1:numel(tmp_files)
        delete(tmp_files{idx})
    end
end



end



