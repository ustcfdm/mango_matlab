function dataType = MgConvertEviDataTypeToMatlabDataType(eviType)
% Convert EVI file data type description into matlab version data type.
% eviType: type description string in EVI file header.
% dataType: data type for Matlab.

switch eviType
    case '16-bit Unsigned'
        dataType = 'uint16';
    case '16-bit Signed'
        dataType = 'int16';
    case '32-bit Unsigned'
        dataType = 'uint32';
    case '32-bit Signed'
        dataType = 'int32';
    case 'Single'
        dataType = 'single';
    otherwise
        dataType = eviType;
end

end

