function A = MgGetAtomicA(atom)
% Get the atomic mass of element (g/mol).
% atom: e.g. "H", "O", "Ca"

switch atom
    case "H"
        A = 1.007970;
    case "He"
        A = 4.002600;
    case "Li"
        A = 6.941000;
    case "Be"
        A = 9.012180;
    case "B"
        A = 10.810000;
    case "C"
        A = 12.011000;
    case "N"
        A = 14.006700;
    case "O"
        A = 15.999400;
    case "F"
        A = 18.998403;
    case "Ne"
        A = 20.179000;
    case "Na"
        A = 22.989770;
    case "Mg"
        A = 24.305000;
    case "Al"
        A = 26.981540;
    case "Si"
        A = 28.085500;
    case "P"
        A = 30.973760;
    case "S"
        A = 32.060000;
    case "Cl"
        A = 35.453000;
    case "Ar"
        A = 39.948000;
    case "K"
        A = 39.098300;
    case "Ca"
        A = 40.080000;
    case "Sc"
        A = 44.955900;
    case "Ti"
        A = 47.900000;
    case "V"
        A = 50.941500;
    case "Cr"
        A = 51.996000;
    case "Mn"
        A = 54.938000;
    case "Fe"
        A = 55.847000;
    case "Co"
        A = 58.933200;
    case "Ni"
        A = 58.700000;
    case "Cu"
        A = 63.546000;
    case "Zn"
        A = 65.380000;
    case "Ga"
        A = 69.720000;
    case "Ge"
        A = 72.590000;
    case "As"
        A = 74.921600;
    case "Se"
        A = 78.960000;
    case "Br"
        A = 79.904000;
    case "Kr"
        A = 83.800000;
    case "Rb"
        A = 85.467800;
    case "Sr"
        A = 87.620000;
    case "Y"
        A = 88.905900;
    case "Zr"
        A = 91.220000;
    case "Nb"
        A = 92.906400;
    case "Mo"
        A = 95.940000;
    case "Tc"
        A = 98.000000;
    case "Ru"
        A = 101.070000;
    case "Rh"
        A = 102.905500;
    case "Pd"
        A = 106.400000;
    case "Ag"
        A = 107.868000;
    case "Cd"
        A = 112.410000;
    case "In"
        A = 114.820000;
    case "Sn"
        A = 118.690000;
    case "Sb"
        A = 121.750000;
    case "Te"
        A = 127.600000;
    case "I"
        A = 126.904500;
    case "Xe"
        A = 131.300000;
    case "Cs"
        A = 132.905400;
    case "Ba"
        A = 137.330000;
    case "La"
        A = 138.905500;
    case "Ce"
        A = 140.120000;
    case "Pr"
        A = 140.907700;
    case "Nd"
        A = 144.240000;
    case "Pm"
        A = 145.000000;
    case "Sm"
        A = 150.400000;
    case "Eu"
        A = 151.960000;
    case "Gd"
        A = 157.250000;
    case "Tb"
        A = 158.925400;
    case "Dy"
        A = 162.500000;
    case "Ho"
        A = 164.930400;
    case "Er"
        A = 167.260000;
    case "Tm"
        A = 168.934200;
    case "Yb"
        A = 173.040000;
    case "Lu"
        A = 174.967000;
    case "Hf"
        A = 178.490000;
    case "Ta"
        A = 180.947900;
    case "W"
        A = 183.850000;
    case "Re"
        A = 186.207000;
    case "Os"
        A = 190.200000;
    case "Ir"
        A = 192.220000;
    case "Pt"
        A = 195.090000;
    case "Au"
        A = 196.966500;
    case "Hg"
        A = 200.590000;
    case "Tl"
        A = 204.370000;
    case "Pb"
        A = 207.200000;
    case "Bi"
        A = 208.980400;
    case "Po"
        A = 209.000000;
    case "At"
        A = 210.000000;
    case "Rn"
        A = 222.000000;
    case "Fr"
        A = 223.000000;
    case "Ra"
        A = 226.025400;
    case "Ac"
        A = 227.027800;
    case "Th"
        A = 232.038100;
    case "Pa"
        A = 231.035900;
    case "U"
        A = 238.029000;
    case "Np"
        A = 237.048200;
    case "Pu"
        A = 242.000000;
    case "Am"
        A = 243.000000;
    case "Cm"
        A = 247.000000;
    case "Bk"
        A = 247.000000;
    case "Cf"
        A = 251.000000;
    case "Es"
        A = 252.000000;
    case "Fm"
        A = 257.000000;
    case "Md"
        A = 258.000000;
    case "No"
        A = 250.000000;
    case "Lr"
        A = 260.000000;
    case "Rf"
        A = 261.000000;
    case "Db"
        A = 262.000000;
    case "Sg"
        A = 263.000000;
    case "Bh"
        A = 262.000000;
    case "Hs"
        A = 255.000000;
    case "Mt"
        A = 256.000000;
    otherwise
        error("Unknown element '%s'\n", atom);
        
end

end

