function MgSaveToJsonFile(data, filename)
% json = MgSaveToJsonFile(data, filename)
% This function encode struct 'data' to text file 'filename'. If the
% file already exists, it will overwrite it (be careful).
% data: struct.
% filename: json file name.

fid = fopen(filename, 'w');
fprintf(fid, "%s", jsonencode(data));
fclose(fid);

end

