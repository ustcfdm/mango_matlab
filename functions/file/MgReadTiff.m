function data = MgReadTiff(filename)
% data = MgReadRawFile(filename)
% This function reads tiff file as a volume. Arguments:
% filename: the name of the file


warning('off', 'imageio:tiffmexutils:libtiffWarning');

t = Tiff(filename, 'r');
info = imfinfo(filename);

w = info(1).Width;
h = info(1).Height;
s = length(info);

data = zeros(h, w, s);

for k = 1:s
    t.setDirectory(k);
    data(:,:,k) = cast(t.read(), 'double');
end

t.close();

warning('on', 'imageio:tiffmexutils:libtiffWarning');

end

