function F_mat = MgGetMaterialDecompMatrix(material_left, material_right, energy)
% Get the material decomposition coefficient matrix. For example:
%                 [mu_PMMA; mu_Al] = F_mat * [mu_water; mu_Ca]
% material_left: cell of material name or 1xN mu vector (e.g. {'PMMA', mu_Al})
% material_left: cell of material name or 1xN mu vector (e.g. {'water', mu_Ca})
% energy: (keV) 1xN vector

n = numel(material_left);
m = numel(energy);

% build matrix of material_left
M_left = zeros(n, m);
for k = 1:n
    if ischar(material_left{k}) || isstring(material_left{k})
        M_left(k,:) = MgGetLinearAttenuation(material_left{k}, energy);
    else
        M_left(k,:) = material_left{k};
    end
end

% build matrix of material_left
M_right = zeros(n, m);
for k = 1:n
    if ischar(material_right{k}) || isstring(material_right{k})
        M_right(k,:) = MgGetLinearAttenuation(material_right{k}, energy);
    else
        M_right(k,:) = material_right{k};
    end
end

% Find F_mat by least square fitting
F_mat = (M_left*M_right') / (M_right*M_right');

end

