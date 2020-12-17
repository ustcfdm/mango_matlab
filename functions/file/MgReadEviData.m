function [img, header] = MgReadEviData(filename)
% img = MgReadEvi(filename)
% Read EVI file data.
% img: image data.
% header: header info.

header = MgReadEviInfo(filename);

switch header.Image_Type
    case '16-bit Unsigned'
        dataType = 'uint16';
    case '16-bit Signed'
        dataType = 'int16';
    case '32-bit Unsigned'
        dataType = 'uint32';
    case '32-bit Signed'
        dataType = 'int32';
    otherwise
        dataType = header.Image_Type;
end

img = MgReadRawFile(filename, header.Height, header.Width, header.Nr_of_images, header.Offset_To_First_Image, header.Gap_between_iamges_in_bytes, dataType);

end

