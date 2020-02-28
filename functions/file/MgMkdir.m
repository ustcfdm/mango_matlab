function MgMkdir(dirName, overwrite)
% MgMkdir(dirName, overwrite)
% This function creates a directory called dirName. Arguments:
% dirName: directory name.
% overwrite: true/false, whether to overwrite if the directory already exists.

if nargin < 2
    overwrite = false;
end

if exist(dirName, 'dir') == 7
    if overwrite == true
        rmdir(dirName, 's');
    else
        return;
    end
end

mkdir(dirName);

end

