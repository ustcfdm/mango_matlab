function ne = MgGetElectronDensity(formula, density)
% Calculate electron density from molecular formula and mass density.
% formula: e.g. 'H2O'
% density: mass density [g/cm3]
% ne: electron density [mol/cm3]

[elements, counts] = MgParseMolecularFormula(formula);

Z = zeros(size(elements));
A = zeros(size(elements));

for n = 1:numel(elements)
    Z(n) = MgGetAtomicZ(elements{n});
    A(n) = MgGetAtomicA(elements{n});
end

m = A .* counts;

ne = sum(m.*Z./A) * density / sum(m);

end

