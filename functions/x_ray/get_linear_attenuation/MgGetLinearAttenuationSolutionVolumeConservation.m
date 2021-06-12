function [mu, density] = MgGetLinearAttenuationSolutionVolumeConservation(material, energy, concentration)
% Get the linear attenuation of material under the assumption of volume conservation [cm^-1].
% mu: mu of solution (/cm)
% density: density of solution (g/mL)
% material: "CaCl2", or ["I", "Gd"]
% energy: between 1 and 150 keV.
% concentration: same size as material [mg/mL].

material = convertCharsToStrings(material);

% volume of each material (mL)
V = zeros(1, numel(material));
% mass of each material (g)
m = zeros(1, numel(material));

for idx = 1:numel(material)
    m(idx) = concentration(idx)/1000;
    V(idx) = m(idx)/MgGetMaterialDensity(material(idx)); % mL
end

% volume and mass of water
V_w = 1 - sum(V); % mL
m_w = V_w * MgGetMaterialDensity('water'); % g

% total mass of solution
M = m_w + sum(m);

% calculate mu
mu_water = MgGetLinearAttenuation("water", energy);
mu = m_w/M * mu_water / MgGetMaterialDensity('water');
for idx = 1:numel(material)
    mu_material = MgGetLinearAttenuation(material(idx), energy);
    mu = mu + m(idx)/M * mu_material/MgGetMaterialDensity(material(idx));
end

density = M / 1; 
mu = mu * density;

end