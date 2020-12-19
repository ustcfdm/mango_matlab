function [img_absorp, img_dark, img_phase] = MgDpcMultiContrast(obj_3d, air_3d, phasePeriod, sampleInterval)
% [img_absorp, img_dark, img_phase] = MgDpcMultiContrast(obj_3d, air_3d, phasePeriod, sampleInterval)
% Calculate DPC multi contrast images.
% obj_3d: [M x N x S] projection data with object.
% air_3d: [M x N x S] projection data of air.
% phasePeriod (optional): phase step size, defalut is S.
% sampleInterval (optional): sample interval along z direction, default is phasePeriod.

[rows, cols, S] = size(obj_3d);

if nargin == 3
    phasePeriod = S;
    sampleInterval = S;
elseif nargin == 4
    sampleInterval = phasePeriod;
end

M = phasePeriod;
T = sampleInterval;

if S-M+1 > 0
    kArray = [1:T:(S-M), S-M+1];
else
     kArray = 1:T:(S-M);
end
N = numel(kArray);

img_absorp = zeros(rows, cols, N);
img_dark = zeros(rows, cols, N);
img_phase = zeros(rows, cols, N);

k = reshape(1:S, 1, 1, []);

cos_array = cos(2*pi*k/M);
sin_array = sin(2*pi*k/M);
obj_cos = obj_3d .* cos_array;
obj_sin = obj_3d .* sin_array;
air_cos = air_3d .* cos_array;
air_sin = air_3d .* sin_array;

for n = 1:N
    idx = kArray(n)+(0:M-1);
    obj_cos_sum = sum(obj_cos(:, :, idx), 3);
    obj_sin_sum = sum(obj_sin(:, :, idx), 3);
    air_cos_sum = sum(air_cos(:, :, idx), 3);
    air_sin_sum = sum(air_sin(:, :, idx), 3);
    
    % absorp
    img_absorp(:,:,n) = log(mean(air_3d(:,:,idx),3) ./ mean(obj_3d(:,:,idx),3));
    
    % dark
    img_dark(:,:,n) = log((air_cos_sum.^2+air_sin_sum.^2)./(obj_cos_sum.^2+obj_sin_sum.^2))/2 - img_absorp(:,:,n);
    
    % phase
    obj_phase = angle(obj_cos_sum - 1i * obj_sin_sum);
    air_phase = angle(air_cos_sum - 1i * air_sin_sum);
    img_phase(:,:,n) = angle(exp(1i * (obj_phase - air_phase)));
end

img_absorp = mean(img_absorp, 3);
img_dark = mean(img_dark, 3);
img_phase = mean(img_phase, 3);

end

