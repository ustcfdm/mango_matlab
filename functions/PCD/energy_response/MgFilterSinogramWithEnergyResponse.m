function sgm_out = MgFilterSinogramWithEnergyResponse(sgm_in, R)
% sgm_out = MgFilterSinogramWithEnergyResponse(sgm_in, R)
% Filter the pre-log sinogram data with energy response funciton.
% sgm_in: [rows, cols, 120] (3rd dimension is energy)
% R: [120, 120] energy response matrix
% sgm_out: [rows, cols, 120]

if size(sgm_in, 3) ~= 120
    fprintf("The input sinogram 3rd dimension must be 120!\n");
    return;
end

rows = size(sgm_in, 1);
cols = size(sgm_in, 2);

sgm_out = zeros(rows*cols, 1, 120);


% reshape sgm_in to [rows x cols, 120]
sgm_in = reshape(sgm_in, rows*cols, 120);

% change shape of R to [1, 120, 120]
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

% reshape sgm_out to [rows, cols, 120]
sgm_out = reshape(sgm_out, rows, cols, 120);


end

