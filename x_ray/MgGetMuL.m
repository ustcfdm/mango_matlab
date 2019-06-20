function muL = MgGetMuL(material, thicknessOrConcentration, type, energy)
%For a given mateiral, return its mu*l.
% material: e.g. "I", "CaCl2"
% thicknessOrConcentration: thickness [mm] or Concentration [mg/mL]
% type: "solid" or "solution"
% energy: [keV]

material = convertCharsToStrings(material);

if material == "none"
    muL = 0;
elseif type == "solid"
    mu = MgGetLinearAttenuation(material, energy);
    muL = mu * thicknessOrConcentration/10;
elseif type == "solution"
    muL = MgGetLinearAttenuationSolution(material, energy, thicknessOrConcentration);
else
    error("Invalid type : %s!\n", type);
end

end

