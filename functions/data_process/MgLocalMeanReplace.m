function [img, idx_mean] = MgLocalMeanReplace(img, binShape)
% Locally replace image pixel if the given small ROI contains 0.
% img: img data will be locally mean.
% idx_mean: index of data with local mean.


rowsBin = size(img,1) / binShape(1);
colsBin = size(img,2) / binShape(2);

idx_mean = zeros(size(img), 'logical');

for i = 1:rowsBin
    for j = 1:colsBin
        rows = i*binShape(1)-binShape(1)+1 : i*binShape(1);
        cols = j*binShape(2)-binShape(2)+1 : j*binShape(2);
        
        % if the ROI contains 0 counts
        idx_1d = max(img(rows,cols,:) < 0.5, [], [1, 2]);
        idx_mean(rows,cols,:) = repmat(idx_1d, binShape);
        
        img(rows,cols,idx_1d) = repmat(mean(img(rows,cols,idx_1d), [1, 2]), binShape);
    end
end

end



