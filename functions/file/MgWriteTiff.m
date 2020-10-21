function MgWriteTiff(filename, data, window, dataType)
% MgWriteTiff(filename, data, dataType)
% This function write image volume to a tiff file. Arguments:
% filename: the name of the file
% data: the image volume
% dataType: 'single' (default), 'uint16', 'int16' ....

if nargin < 4
    dataType = 'single';
end

t = Tiff(filename, 'w');

tag.ImageLength = size(data, 1);
tag.ImageWidth = size(data, 2);
tag.BitsPerSample = MgGetTypeBytes(dataType) * 8;
tag.SamplesPerPixel = 1;
tag.Compression = Tiff.Compression.None;
tag.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
tag.Photometric = Tiff.Photometric.MinIsBlack;

if nargin > 2
    tag.ImageDescription = sprintf('ImageJ=1.51w\nmin=%f\nmax=%f', window(1), window(2));
end

% get sample format
if contains(dataType, 'uint')
    tag.SampleFormat = Tiff.SampleFormat.UInt;
elseif contains(dataType, 'int')
    tag.SampleFormat = Tiff.SampleFormat.Int;
elseif strcmp(dataType, 'single')
    tag.SampleFormat = Tiff.SampleFormat.IEEEFP;
else
    fprintf('Unsupported data type: %s!\n', dataType);
    return
end

for k = 1:size(data, 3)
    setTag(t, tag);
    write(t, cast(data(:,:,k), dataType));
    writeDirectory(t);
end

close(t);


end

