function [files_short, files_long] = MgBenchtopGetEviFileNames(objectName, objectIndex, energyBin)
% This is a function specific for benchtop PCD-CT procedure. It acquires
% the file name list of EVI data. If it is "LE" which doesn't exist, this
% function will generate LE data from TE and HE data.

if energyBin ~= "LE"
    [files_short, files_long] = MgDirRegExpV2(sprintf('./EVI/%s', objectName), sprintf('%s_%s.EVI', objectIndex, energyBin));
else
    [files_TE_short, files_TE_long] = MgDirRegExpV2(sprintf('./EVI/%s', objectName), sprintf('%s_TE.EVI', objectIndex));
    [files_HE_short, files_HE_long] = MgDirRegExpV2(sprintf('./EVI/%s', objectName), sprintf('%s_HE.EVI', objectIndex));
    for n = 1:numel(files_TE_short)
        file_LE = strrep(files_HE_long{n}, '_HE.EVI', '_LE.EVI');
        if ~isfile(file_LE)
            MgConvertHeTeToLe(files_TE_long{n}, files_HE_long{n}, file_LE);
        end
    end
    [files_short, files_long] = MgDirRegExpV2(sprintf('./EVI/%s', objectName), sprintf('%s_LE.EVI', objectIndex));
end

end

