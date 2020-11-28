function sgm_out = MgFilterSinogramWithEnergyResponse(sgm_in, R)
% sgm_out = MgFilterSinogramWithEnergyResponse(sgm_in, R)
% Filter the pre-log sinogram data with energy response funciton.
% sgm_in: [rows, cols, 150] (3rd dimension is energy)
% R: [150, 150] energy response matrix
% sgm_out: [rows, cols, 150]

if size(sgm_in, 3) ~= 150
    fprintf("The input sinogram 3rd dimension must be 150!\n");
    return;
end

rows = size(sgm_in, 1);
cols = size(sgm_in, 2);

sgm_out = zeros(rows*cols, 1, 150);


% reshape sgm_in to [rows x cols, 150]
sgm_in = reshape(sgm_in, rows*cols, 150);

% change shape of R to [1, 150, 150]
R = permute(R, [3, 2, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do the energy response function transformation
% N could be very large, let's divide it into several parts and apply energy response seperately
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
length = 10000;
loops = floor(size(sgm_in,1)/length);
range = 1:length;
for k = 1:loops
    sgm_out(range,1,:) = sum(sgm_in(range,:).*R,2);
    range = range + length;
end
range = range(1):size(sgm_in,1);
sgm_out(range,1,:) = sum(sgm_in(range,:).*R,2);

% reshape sgm_out to [rows, cols, 150]
sgm_out = reshape(sgm_out, rows, cols, 150);


end

