"""
# Physical Constants Module

This module provides all necessary physical constants for computational physics,
with proper units and high precision values.

All constants are provided with Unitful.jl units for dimensional analysis
and automatic unit conversion.
"""

# Import necessary packages
using PhysicalConstants.CODATA2018
using Unitful
using UnitfulAstro

"""
    PhysicsConstants

A comprehensive collection of physical constants used in computational physics.
All constants include proper units and are based on CODATA 2018 values.
"""
struct PhysicsConstants
    # Fundamental constants
    c::typeof(SpeedOfLightInVacuum)           # Speed of light
    ħ::typeof(ReducedPlanckConstant)          # Reduced Planck constant
    h::typeof(PlanckConstant)                 # Planck constant
    e::typeof(ElementaryCharge)               # Elementary charge
    k_B::typeof(BoltzmannConstant)            # Boltzmann constant
    N_A::typeof(AvogadroConstant)             # Avogadro constant
    
    # Electromagnetic constants
    ε₀::typeof(VacuumElectricPermittivity)    # Vacuum permittivity
    μ₀::typeof(VacuumMagneticPermeability)    # Vacuum permeability
    α::typeof(FineStructureConstant)          # Fine structure constant
    
    # Particle masses (in natural units and SI)
    m_e::typeof(ElectronMass)                 # Electron mass
    m_p::typeof(ProtonMass)                   # Proton mass
    m_n::typeof(NeutronMass)                  # Neutron mass
    
    # Gravitational constant
    G::typeof(NewtonianConstantOfGravitation) # Gravitational constant
    
    # Atomic units (Hartree atomic units)
    a₀::typeof(BohrRadius)                    # Bohr radius
    E_h::typeof(HartreeEnergy)                # Hartree energy
    
    # Nuclear physics
    r₀::Unitful.Length                        # Nuclear radius parameter
    
    # Mathematical constants
    π::Float64
    ℯ::Float64
    γ::Float64                                # Euler-Mascheroni constant
    
    # Yukawa potential specific
    λ_c::Unitful.Length                       # Compton wavelength
    r_classical::Unitful.Length               # Classical electron radius
end

"""
    PhysicsConstants()

Constructor for PhysicsConstants with all standard values.
"""
function PhysicsConstants()
    # Calculate derived constants
    λ_c = ReducedPlanckConstant / (ElectronMass * SpeedOfLightInVacuum)
    r_classical = ElementaryCharge^2 / (4π * VacuumElectricPermittivity * ElectronMass * SpeedOfLightInVacuum^2)
    r₀ = 1.2e-15u"m"  # Nuclear radius parameter
    
    return PhysicsConstants(
        SpeedOfLightInVacuum,
        ReducedPlanckConstant,
        PlanckConstant,
        ElementaryCharge,
        BoltzmannConstant,
        AvogadroConstant,
        VacuumElectricPermittivity,
        VacuumMagneticPermeability,
        FineStructureConstant,
        ElectronMass,
        ProtonMass,
        NeutronMass,
        NewtonianConstantOfGravitation,
        BohrRadius,
        HartreeEnergy,
        r₀,
        π,
        ℯ,
        0.5772156649015329,  # Euler-Mascheroni constant
        λ_c,
        r_classical
    )
end

# Global instance of constants
const CONSTANTS = PhysicsConstants()

# Convenience accessors for common constants
const c = CONSTANTS.c
const ħ = CONSTANTS.ħ
const h = CONSTANTS.h
const e = CONSTANTS.e
const k_B = CONSTANTS.k_B
const ε₀ = CONSTANTS.ε₀
const μ₀ = CONSTANTS.μ₀
const α = CONSTANTS.α
const m_e = CONSTANTS.m_e
const m_p = CONSTANTS.m_p
const a₀ = CONSTANTS.a₀
const E_h = CONSTANTS.E_h

"""
    natural_units()

Return a dictionary of natural units (ħ = c = 1) for theoretical calculations.
"""
function natural_units()
    return Dict(
        :ħ => 1.0,
        :c => 1.0,
        :length_unit => "ħ/(mc)",
        :energy_unit => "mc²",
        :time_unit => "ħ/(mc²)",
        :description => "Natural units where ħ = c = 1"
    )
end

"""
    atomic_units()

Return a dictionary of atomic units (Hartree atomic units).
"""
function atomic_units()
    return Dict(
        :ħ => 1.0,
        :e => 1.0,
        :m_e => 1.0,
        :a₀ => 1.0,
        :length_unit => "Bohr radius (a₀)",
        :energy_unit => "Hartree (E_h)",
        :time_unit => "ħ/E_h",
        :description => "Atomic units where ħ = e = mₑ = 4πε₀ = 1"
    )
end

"""
    nuclear_units()

Return a dictionary of nuclear units for nuclear physics calculations.
"""
function nuclear_units()
    return Dict(
        :ħ => 1.0,
        :c => 1.0,
        :length_unit => "femtometer (fm)",
        :energy_unit => "MeV",
        :mass_unit => "MeV/c²",
        :description => "Nuclear units with lengths in fm and energies in MeV"
    )
end

"""
    conversion_factor(from_unit, to_unit)

Calculate conversion factors between different unit systems.
"""
function conversion_factor(from_unit::String, to_unit::String)
    conversions = Dict(
        ("eV", "J") => uconvert(u"J", 1.0u"eV").val,
        ("J", "eV") => uconvert(u"eV", 1.0u"J").val,
        ("nm", "m") => 1e-9,
        ("m", "nm") => 1e9,
        ("fs", "s") => 1e-15,
        ("s", "fs") => 1e15,
        ("bohr", "m") => uconvert(u"m", 1.0 * a₀).val,
        ("m", "bohr") => 1.0 / uconvert(u"m", 1.0 * a₀).val
    )
    
    key = (from_unit, to_unit)
    if haskey(conversions, key)
        return conversions[key]
    else
        error("Conversion from $from_unit to $to_unit not implemented")
    end
end

"""
    display_constants()

Display all available physical constants with their values and units.
"""
function display_constants()
    println("🔬 Physical Constants (CODATA 2018)")
    println("=" ^ 50)
    
    constants_list = [
        ("Speed of light", c),
        ("Planck constant", h),
        ("Reduced Planck constant", ħ),
        ("Elementary charge", e),
        ("Boltzmann constant", k_B),
        ("Vacuum permittivity", ε₀),
        ("Vacuum permeability", μ₀),
        ("Fine structure constant", α),
        ("Electron mass", m_e),
        ("Proton mass", m_p),
        ("Bohr radius", a₀),
        ("Hartree energy", E_h)
    ]
    
    for (name, constant) in constants_list
        println(@sprintf("%-25s: %s", name, constant))
    end
    
    println("\n📐 Unit Systems Available:")
    println("• Natural units: natural_units()")
    println("• Atomic units: atomic_units()")
    println("• Nuclear units: nuclear_units()")
end