function array_unbin = MgUnbinArray(array, binShape)
% Unbin array in row and col direction.

rows_unbin = size(array,1) * binShape(1);
cols_unbin = size(array,2) * binShape(2);

array_unbin = zeros(rows_unbin, cols_unbin, size(array,3), class(array));

for i = 1:size(array,1)
    for j = 1:size(array,2)
        rows = i*binShape(1)-binShape(1)+1 : i*binShape(1);
        cols = j*binShape(2)-binShape(2)+1 : j*binShape(2);
        
        array_unbin(rows,cols,:) = repmat(array(i,j,:), binShape);
    end
end


end

