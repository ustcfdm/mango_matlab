function array_bin = MgRebinArray(array, binShape, func)
% Rebin the array with given bin shape. Example:
%   array: 8 × 6 × 10
%   binShape: [2, 3]
%   array_bin: 4 × 2 × 10
% func: function handle (@sum, @mean, @max, @min)

if ndims(array) > numel(binShape)
    binShape(end+1:end+ndims(array)-numel(binShape)) = 1;
end

rowsBin = size(array,1) / binShape(1);
colsBin = size(array,2) / binShape(2);

array_bin = zeros(rowsBin, colsBin, size(array,3), class(array));

if functions(func).function == "sum" || functions(func).function == "mean"
    for i = 1:rowsBin
        for j = 1:colsBin
            rows = i*binShape(1)-binShape(1)+1 : i*binShape(1);
            cols = j*binShape(2)-binShape(2)+1 : j*binShape(2);
            
            array_bin(i,j,:) = func(array(rows,cols,:), [1,2]);
        end
    end
elseif functions(func).function == "max" || functions(func).function == "min"
    for i = 1:rowsBin
        for j = 1:colsBin
            rows = i*binShape(1)-binShape(1)+1 : i*binShape(1);
            cols = j*binShape(2)-binShape(2)+1 : j*binShape(2);
            
            array_bin(i,j,:) = func(array(rows,cols,:), [], [1,2]);
        end
    end
end

end