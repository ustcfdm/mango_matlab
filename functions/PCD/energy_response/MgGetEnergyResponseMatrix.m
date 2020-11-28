function enRes = MgGetEnergyResponseMatrix(acs_mode, a, b)
% Get energy response data matrix (150x150) of PCD.
% acs_mode:  true or false, whether use Anti-Charge sharing (ACS) mode
% a, b: shift the energy response matrix if necessary
%       the corresponding energy is a*E + b
%       the default energy is 1:150
%       shift will convert energy response matrix to 1:150 energy position


% import energy response data matrix
if acs_mode
    enRes = readmatrix('MgEnergyResponseDataAcsOn.txt');
else
    enRes = readmatrix('MgEnergyResponseDataAcsOff.txt');
end

% do the shift
if nargin > 1
    R = zeros(150);
    en = 1:150;
    en_shift = a*en + b;
    for col = 1:150
        R(:,col) = interp1(en_shift, enRes(:,col), en);
    end
    enRes = R;
    enRes(isnan(enRes)) = 0;
end

end
