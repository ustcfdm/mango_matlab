function density = MgGetMaterialDensity(material)
% density = MgGetMaterialDensity(material)
% Get the density of material.
% material: e.g. "water", "air", "Cu", "I".
% density: [g/cm3]

switch material
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %compound
    case "adipose"
        density = 0.95;
    case "air"
        density = 1.205e-3;
    case "blood"
        density = 1.06;
    case "bone"
        density = 1.92;
    case "brain"
        density = 1.04;
    case "CaC2O4"
        density = 2.12;
    case "CaCl2"
        density = 2.15;
    case "CdTe"
        density = 5.85;
    case "CsI"
        density = 4.51;
    case "GOS"
        density = 7.32;
    case "kidney"
        density = 1.05;
    case "liver"
        density = 1.06;
    case "muscle"
        density = 1.05;
    case "NaI"
        density = 3.67;
    case "PMMA"
        density = 1.18;
    case "spleen"
        density = 1.06;
    case "teflon"
        density = 2.2;
    case "tissue"
        density = 1.06;
    case "UricAcid"
        density = 1.87;
    case "water"
        density = 1;
   
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % element
    case "Al"
        density = 2.7;
    case "Au"
        density = 19.3;
    case "C"
        density = 2.26;
    case "Ca"
        density = 1.55;
    case "Ce"
        density = 6.78;
    case "Cl"
        density = 3.17;
    case "Cu"
        density = 8.96;
    case "Fe"
        density = 7.86;
    case "Gd"
        density = 7.89;
    case "H"
        density = 0.0899;
    case "I"
        density = 4.92;
    case "K"
        density = 0.86;
    case "Mg"
        density = 1.74;
    case "N"
        density = 1.251;
    case "Na"
        density = 0.97;
    case "O"
        density = 1.429;
    case "P"
        density = 1.82;
    case "S"
        density = 2.07;
    case "Si"
        density = 2.33;
    case "Sn"
        density = 7.3;
    case "Tm"
        density = 9.33;
    case "W"
        density = 19.3;
    otherwise
        error("Unknown material '%s'\n", material);
        
end

end

