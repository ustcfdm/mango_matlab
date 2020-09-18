function numberArray = MgExtractNumberFromStringCell(cellOfStrings, stringFormat)
% numberArray = MgExtractNumberFromStringCell(cellOfStrings, stringFormat)
% Extract number list from a cell of string.
% For example: 
% cellOfStrings: {'s1', 's10', 's19', 's2'}
% stringFormat: 's%d'
% numberArray: [1, 10, 19, 2]

numberArray = cellfun(@(x)sscanf(x, stringFormat), cellOfStrings);

end

