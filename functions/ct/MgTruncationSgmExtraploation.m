function sgm_corr = MgTruncationSgmExtraploation(sgm, detEleSize, mu, idxLeft, idxRight)
% Do extrapolation for truncated sinogram.
% sgm: truncated sinogram [rows x cols x slices]
% detEleSize: detector element size (mm).
% mu: linear attenuation of object (/mm) (e.g. 0.020 for soft tissue)
% idxLeft: index of left side for slope calculation (e.g. 196:210, then 1:195 will be extrapolated).
% idxRight: idex of right side for slope calculation.
% sgm_corr: sinogram after extraploation.

if nargin < 2
    mu = 0.017;
end

% detector element size [mm]
dx = detEleSize;

[M, N, S] = size(sgm);


for slice = 1:S
    % start interp
    for row = 1:M
        %-----------------------------------
        % left
        %-----------------------------------
        p = sgm(row, idxLeft(1), slice);
        % calculate slope
        s = polyfit(idxLeft, sgm(row, idxLeft, slice), 1);
        s = s(1);
        % position x
        x = p*s/(4*mu^2);
        % radius R
        R = sqrt(p^2/(4*mu^2) + x^2);
        
        idx = idxLeft(1);
        for col = 1:idx-1
            r = (idx - col) * dx;
            if r < abs(R)
                sgm(row, col, slice) = 2*mu * sqrt(R^2 - r^2);
            end
        end
        
        %-----------------------------------
        % right
        %-----------------------------------
        p = sgm(row, idxRight(end), slice);
        % calculate slope
        s = polyfit(idxRight, sgm(row, idxRight, slice), 1);
        s = s(1);
        % position x
        x = p*s/(4*mu^2);
        % radius R
        R = sqrt(p^2/(4*mu^2) + x^2);
        
        idx = idxRight(end);
        for col = idx+1:N
            r = (col - idx) * dx;
            if r < abs(R)
                sgm(row, col, slice) = 2*mu * sqrt(R^2 - r^2);
            end
        end
        
    end
    ratio = sgm(:, idxLeft(1), slice) ./ sgm(:, idxLeft(1)-1, slice);
    sgm(:, 1:idxLeft(1)-1, slice) = sgm(:, 1:idxLeft(1)-1, slice) .* ratio;
    
    ratio = sgm(:, idxRight(end), slice) ./ sgm(:, idxRight(end)+1, slice);
    sgm(:, idxRight(end)+1:N, slice) = sgm(:, idxRight(end)+1:N, slice) .* ratio;
end

sgm_corr = sgm;

end

