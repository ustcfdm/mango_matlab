function header = MgReadEviInfo(filename)
% img = MgReadEvi(filename)
% Read EVI file header information.

[fid, errmsg] = fopen(filename, 'r', 'l');
while true
    [left, right] = strtok(fgetl(fid));
    % try to convert some string to number
    [value, tf] = str2num(right);
    % assign value
    if tf 
        header.(left) = value;
    else
        header.(left) = strtrim(right);
    end
    
    if left == "COMMENT"
        break;
    end
end
fclose(fid);


end

