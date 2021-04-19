function mu = MgGetLinearAttenuationGammex(material, concentration, energy)
% Get the linear attenuation coefficients of Gammex inserts.
% material: 'I' or 'Ca'.
% concentration: nominal insert concentration (mg/mL).
% energy: energy array (1~150 keV).
% mu: mu of Gammex insert (/cm).

if material == "I"
    t = importdata('iodine_inserts.txt');
elseif material == "Ca"
    t = importdata('calcium_inserts.txt');
else
    error('Unknown insert material %s!\n', material);
end

% n: index of a certain 
n = find(t.data(:,1) == concentration, 1);
if isempty(n)
    error('Unknown insert concentraion %g of %s!\n', concentration, material);
end

% start calculating the attenuation
mu = 0;
for m = 4:size(t.data, 2)
    mu = mu + t.data(n,m)/100 * MgGetLinearAttenuation(strtrim(t.textdata{m}), energy) / MgGetMaterialDensity(strtrim(t.textdata{m}));
end
% multiplied by insert density
mu = mu * t.data(n, 2);


end

