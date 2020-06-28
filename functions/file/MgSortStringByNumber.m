function cellOfStringSorted = MgSortStringByNumber(cellOfStrings, stringFormat)
% cellOfStringSorted = MgSortStringByNumber(cellOfStrings, stringFormat)
% Sort cell of strings including numbers based on numbers.
% For example: 
% cellOfStrings: {'s1', 's10', 's19', 's2'}
% stringFormat: 's%d'
% cellOfStringSorted: {'s1', 's2', 's10', 's19'}

tmp = cellfun(@(x)sscanf(x, stringFormat), cellOfStrings);
[~, sidx] = sort(tmp);
cellOfStringSorted = cellOfStrings(sidx);

end

