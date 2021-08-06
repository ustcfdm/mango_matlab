function [elements, counts] = MgParseMolecularFormula(formula_string)
% Parse a molecular formula and return its elements and corresponding counts.
% Example: formula_string = 'H2O'
%          elements = {'H', 'O'}
%          counts = [2, 1]

% string length
n = strlength(formula_string);

% analyze elements and counts of material
formula_string = convertStringsToChars(formula_string);

elements = {formula_string(1)};
counts = [0];

k = 2;
while k <= n
    if formula_string(k) >= 'a' && formula_string(k) <= 'z'
        elements{end} = [elements{end}, formula_string(k)];
    elseif formula_string(k) >= 'A' && formula_string(k) <= 'Z'
        elements{end+1} = formula_string(k);
        if counts(end) == 0
            counts(end) = 1;
        end
        counts(end+1) = 0;
    elseif formula_string(k) >= '0' && formula_string(k) <= '9'
        counts(end) = counts(end) * 10 + str2num(formula_string(k));
    end
    k = k + 1;
end
if counts(end) == 0
    counts(end) = 1;
end


end

