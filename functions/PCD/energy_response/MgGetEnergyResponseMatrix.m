function enRes = MgGetEnergyResponseMatrix(a, b)
% Get energy response data matrix (120x120) of PCD.
% a, b: shift the energy response matrix if necessary
%       the corresponding energy is a*E + b
%       the default energy is 1:120
%       shift will convert energy response matrix to 1:120 energy position

enRes = importdata('MgEnergyResponseData.txt');

% do the shift
if nargin > 0
    R = zeros(120);
    en = 1:120;
    en_shift = a*en + b;
    for col = 1:120
        R(:,col) = interp1(en_shift, enRes(:,col), en);
    end
    enRes = R;
    enRes(isnan(enRes)) = 0;
end

end
