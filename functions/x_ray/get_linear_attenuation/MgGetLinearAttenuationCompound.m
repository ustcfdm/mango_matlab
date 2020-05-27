function mu = MgGetLinearAttenuationCompound(density, energy, varargin)
% Get the linear attenuation of the compound material [cm^-1].
% density: the density of the material [g/cm3]
% energy: energy array [keV]
% varargin: element and its mass fraction (e.g. 'C', 0.18)

mu = zeros(size(energy));

N = nargin - 2;

for k = 1:2:N
    % element name
    ele = varargin{k};
    % element mass fraction
    fm = varargin{k+1};
    
    mu_ele = MgGetLinearAttenuation(ele, energy);
    
    mu = mu + fm * mu_ele / MgGetMaterialDensity(ele);
end

mu = mu * density;

end

