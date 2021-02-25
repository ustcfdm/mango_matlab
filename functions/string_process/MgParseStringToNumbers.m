function numbers = MgParseStringToNumbers(in_str)
% Parse a string to integer numbers.
% e.g. string '1,3-5,7' will be converted to numbers [1, 3, 4, 5, 7];
% in_str: input string.
% numbers: output integer numbers.

numbers = [];
s1 = strsplit(in_str, ',');

% whether the substring contains '-'
containDash = contains(s1, '-');

idx = 1;
for n = 1:numel(s1)
    if containDash(n)
        s2 = strsplit(s1{n}, '-');
        a = str2num(s2{1});
        b = str2num(s2{2});
        numbers((0:b-a)+idx) = a:b;
        idx = idx + b-a+1;
    else
        numbers(idx) = str2num(s1{n});
        idx = idx + 1;
    end
    
end


end

