function idx_group = MgMergeContinuousIndex(index)
% Merge continuous interger numbers. For example, the input index is:
%   2,3,4,5, 8,9,10,11. 
% Then the output will be:
%   {[2,5], [8,11]}

index = sort(index);

idx_group{1} = index(1);

g = 1;
for n = 2:numel(index)
    idx_group{g}(2) = index(n-1);
    
    if index(n) > index(n-1) + 1
        g = g + 1;
        idx_group{g}(1) = index(n);
    end
end
idx_group{g}(2) = index(n);

end

