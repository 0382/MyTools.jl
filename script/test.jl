using AtomicMassEvaluation

function Sn(isotope)
    iso = Isotope(isotope)
    piso = Isotope(iso.Z, iso.N-1)
    return binding_energy(get(AME2020, iso)) - binding_energy(get(AME2020, piso))
end

function Sn2(isotope)
    iso = Isotope(isotope)
    piso = Isotope(iso.Z, iso.N-2)
    return binding_energy(get(AME2020, iso)) - binding_energy(get(AME2020, piso))
end

function Sp(isotope)
    iso = Isotope(isotope)
    piso = Isotope(iso.Z-1, iso.N)
    return binding_energy(get(AME2020, iso)) - binding_energy(get(AME2020, piso))
end

function Sp2(isotope)
    iso = Isotope(isotope)
    piso = Isotope(iso.Z-2, iso.N)
    return binding_energy(get(AME2020, iso)) - binding_energy(get(AME2020, piso))
end
