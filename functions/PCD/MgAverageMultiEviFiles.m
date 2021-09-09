function MgAverageMultiEviFiles(file_out, files_in)
% Take the average of multiple EVI files, out EVI is in "Single" type.
% filesname_out: output file name.
% files_in: a cell array, the nmae list of multiple files.

fprintf('Averaging EVI:     ');
%==================================================
% Read header info
%==================================================
header = MgReadEviInfo(files_in{1});
rows = header.Height;
cols = header.Width;
pages = header.Nr_of_images;
offset = header.Offset_To_First_Image;
gap = header.Gap_between_iamges_in_bytes;
dataType = MgConvertEviDataTypeToMatlabDataType(header.Image_Type);


%==================================================
% Write header info
%==================================================
% open the TE file and get head info
fid_tmp = fopen(files_in{1}, 'r', 'l');
header_str = fread(fid_tmp, [1,offset], '*char');
fclose(fid_tmp);

header_out = strrep(header_str, header.Image_Type, 'Single');
N = numel(header_out);

fid_out = fopen(file_out, 'w');

if N >= offset
    header_out = header_out(1:offset);
    fwrite(fid_out, header_out(1:offset), 'uchar');
else
    fwrite(fid_out, header_out, 'uchar');
    fwrite(fid_out, zeros(1, offset-N, 'int8'), 'int8');
end



%==================================================
% Write data volume
%==================================================
% numer of input files
N = numel(files_in);
fid_in = cell(N, 1);
% open file pointer
for n = 1:N
    fid_in{n} = fopen(files_in{n}, 'r', 'l');
    fseek(fid_in{n}, offset, 'bof');
end

img_tmp = zeros(rows*cols, N);
gapArray = zeros(1, gap, 'int8');

for page = 1:pages
    for n = 1:N
        img_tmp(:,n) = fread(fid_in{n}, rows*cols, dataType);
    end
    fwrite(fid_out, mean(img_tmp, 2), 'single');
    
    if page < pages
        for n = 1:N
            fseek(fid_in{n}, gap, 'cof');
        end
        fwrite(fid_out, gapArray, 'int8');
    end
    fprintf('\b\b\b\b%3.f%%', page/pages*100);
end

fclose(fid_out);
for n = 1:N
    fclose(fid_in{n});
end

fprintf('\n');

end

