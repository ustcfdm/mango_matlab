function MgGetBoneCorrectionConfigSampleFile(filename)
% MgGetBoneCorrectionConfigSampleFile(filename)
% Get a config sample file for bone beam hardening correction.
% filename: the sample content will be saved to filename.

% copyfile('config_sample_bone_correction.jsonc', filename);

js = fileread('config_sample_bone_correction.jsonc');

fid = fopen(filename, 'w');
fprintf(fid, "%s", js);
fclose(fid);

end