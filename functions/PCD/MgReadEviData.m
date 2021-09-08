function [img, header] = MgReadEviData(filename)
% img = MgReadEvi(filename)
% Read EVI file data.
% img: image data.
% header: header info.

header = MgReadEviInfo(filename);

dataType = MgConvertEviDataTypeToMatlabDataType(header.Image_Type);

img = MgReadRawFile(filename, header.Height, header.Width, header.Nr_of_images, header.Offset_To_First_Image, header.Gap_between_iamges_in_bytes, dataType);

end

