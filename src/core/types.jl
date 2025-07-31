"""
# Core Types Module

This module defines all fundamental types used throughout the YukawaPhysics package.
These types provide structure, type safety, and performance optimization for
computational physics calculations.

## Type Hierarchy

The types are organized hierarchically:
- Abstract physics types for dispatch
- Concrete implementations for specific physics problems
- Parameter types for configuration
- Result types for storing computed data

## Design Philosophy

Types are designed with:
- Performance in mind (using StaticArrays where appropriate)
- Clear mathematical meaning
- Extensibility for future physics problems
- Integration with Julia's multiple dispatch system
"""

using StaticArrays
using Unitful
using LinearAlgebra

# ============================================================================
# Abstract Types for Physics Systems
# ============================================================================

"""
    AbstractPhysicsSystem

Abstract supertype for all physics systems in the package.
"""
abstract type AbstractPhysicsSystem end

"""
    AbstractPotential

Abstract supertype for all potential energy functions.
"""
abstract type AbstractPotential end

"""
    AbstractQuantumState

Abstract supertype for quantum mechanical states.
"""
abstract type AbstractQuantumState end

"""
    AbstractClassicalSystem

Abstract supertype for classical mechanical systems.
"""
abstract type AbstractClassicalSystem <: AbstractPhysicsSystem end

# ============================================================================
# Yukawa Potential Types
# ============================================================================

"""
    YukawaPotential{T<:Real} <: AbstractPotential

Represents a Yukawa potential: V(r) = -g²/(4π) * exp(-μr)/r

# Fields
- `coupling::T`: Coupling constant g
- `mass::T`: Mass parameter μ (inverse range)
- `units::Symbol`: Unit system (:SI, :natural, :atomic, :nuclear)

# Mathematical Form
The Yukawa potential is given by:
```
V(r) = -g²/(4π) * exp(-μr)/r
```

Where:
- g is the coupling constant (dimensionless in natural units)
- μ is the mass parameter (inverse length scale)
- r is the radial distance

# Examples
```julia
# Create Yukawa potential in natural units
V = YukawaPotential(1.0, 1.0, :natural)

# Create with physical units
V_physical = YukawaPotential(1.0u"eV", 1.0u"eV", :SI)
```
"""
struct YukawaPotential{T<:Real} <: AbstractPotential
    coupling::T      # Coupling constant g
    mass::T         # Mass parameter μ
    units::Symbol   # Unit system
    
    function YukawaPotential(coupling::T, mass::T, units::Symbol=:natural) where T<:Real
        @assert mass > 0 "Mass parameter must be positive"
        @assert units in [:SI, :natural, :atomic, :nuclear] "Invalid unit system"
        new{T}(coupling, mass, units)
    end
end

"""
    CoulombPotential{T<:Real} <: AbstractPotential

Coulomb potential as limiting case of Yukawa potential (μ → 0).
V(r) = -α/r where α is the fine structure constant.
"""
struct CoulombPotential{T<:Real} <: AbstractPotential
    charge::T       # Effective charge
    units::Symbol   # Unit system
    
    function CoulombPotential(charge::T, units::Symbol=:atomic) where T<:Real
        new{T}(charge, units)
    end
end

# ============================================================================
# Quantum State Types
# ============================================================================

"""
    QuantumState{T<:Complex, N} <: AbstractQuantumState

Represents a quantum mechanical state with wavefunction data.

# Fields
- `ψ::Vector{T}`: Wavefunction amplitudes
- `r::Vector{Float64}`: Spatial grid points
- `energy::Float64`: Energy eigenvalue (if known)
- `quantum_numbers::NamedTuple`: Quantum numbers (n, l, j, etc.)
- `normalized::Bool`: Whether the state is normalized

# Type Parameters
- `T`: Complex number type for wavefunction
- `N`: Dimension of the space (1D, 2D, 3D)
"""
mutable struct QuantumState{T<:Complex, N} <: AbstractQuantumState
    ψ::Vector{T}                    # Wavefunction
    r::Vector{Float64}              # Spatial grid
    energy::Float64                 # Energy eigenvalue
    quantum_numbers::NamedTuple     # Quantum numbers
    normalized::Bool                # Normalization flag
    
    function QuantumState(ψ::Vector{T}, r::Vector{Float64}, 
                         energy::Float64=NaN, 
                         quantum_numbers::NamedTuple=NamedTuple(),
                         normalized::Bool=false) where T<:Complex
        @assert length(ψ) == length(r) "Wavefunction and grid must have same length"
        new{T,1}(ψ, r, energy, quantum_numbers, normalized)
    end
end

"""
    BoundState{T<:Complex} <: AbstractQuantumState

Specialized type for bound quantum states with discrete energy levels.
"""
struct BoundState{T<:Complex} <: AbstractQuantumState
    ψ::Vector{T}                    # Bound state wavefunction
    r::Vector{Float64}              # Radial grid
    energy::Float64                 # Binding energy (negative)
    n::Int                          # Principal quantum number
    l::Int                          # Angular momentum quantum number
    binding_energy::Float64         # |E| for bound states
    
    function BoundState(ψ::Vector{T}, r::Vector{Float64}, energy::Float64, 
                       n::Int, l::Int) where T<:Complex
        @assert energy < 0 "Bound states must have negative energy"
        @assert n > 0 "Principal quantum number must be positive"
        @assert l >= 0 "Angular momentum quantum number must be non-negative"
        @assert l < n "Must have l < n for bound states"
        
        binding_energy = -energy
        new{T}(ψ, r, energy, n, l, binding_energy)
    end
end

"""
    ScatteringState{T<:Complex} <: AbstractQuantumState

Specialized type for scattering states with continuous energy spectrum.
"""
struct ScatteringState{T<:Complex} <: AbstractQuantumState
    ψ::Vector{T}                    # Scattering wavefunction
    r::Vector{Float64}              # Radial grid
    energy::Float64                 # Scattering energy (positive)
    k::Float64                      # Wave number
    l::Int                          # Angular momentum quantum number
    phase_shift::Float64            # Scattering phase shift δₗ
    
    function ScatteringState(ψ::Vector{T}, r::Vector{Float64}, energy::Float64,
                            k::Float64, l::Int, phase_shift::Float64) where T<:Complex
        @assert energy > 0 "Scattering states must have positive energy"
        @assert k > 0 "Wave number must be positive"
        @assert l >= 0 "Angular momentum quantum number must be non-negative"
        
        new{T}(ψ, r, energy, k, l, phase_shift)
    end
end

# ============================================================================
# Classical System Types
# ============================================================================

"""
    ClassicalParticle{N, T<:Real} <: AbstractClassicalSystem

Represents a classical particle in N-dimensional space.

# Fields
- `position::SVector{N,T}`: Position vector
- `velocity::SVector{N,T}`: Velocity vector
- `mass::T`: Particle mass
- `charge::T`: Electric charge (if applicable)

# Type Parameters
- `N`: Spatial dimension (1, 2, or 3)
- `T`: Numeric type for coordinates
"""
mutable struct ClassicalParticle{N, T<:Real} <: AbstractClassicalSystem
    position::SVector{N,T}      # Position vector
    velocity::SVector{N,T}      # Velocity vector
    mass::T                     # Mass
    charge::T                   # Charge
    
    function ClassicalParticle(pos::SVector{N,T}, vel::SVector{N,T}, 
                              mass::T, charge::T=zero(T)) where {N,T<:Real}
        @assert mass > 0 "Mass must be positive"
        new{N,T}(pos, vel, mass, charge)
    end
end

"""
    PhaseSpace{N, T<:Real}

Represents a point in 2N-dimensional phase space for N-dimensional system.
"""
struct PhaseSpace{N, T<:Real}
    q::SVector{N,T}             # Generalized coordinates
    p::SVector{N,T}             # Generalized momenta
    
    function PhaseSpace(q::SVector{N,T}, p::SVector{N,T}) where {N,T<:Real}
        new{N,T}(q, p)
    end
end

# ============================================================================
# Computational Configuration Types
# ============================================================================

"""
    NumericalParameters{T<:Real}

Configuration parameters for numerical computations.
"""
struct NumericalParameters{T<:Real}
    # Grid parameters
    r_min::T                    # Minimum radius
    r_max::T                    # Maximum radius
    n_points::Int               # Number of grid points
    
    # Integration parameters
    abs_tol::T                  # Absolute tolerance
    rel_tol::T                  # Relative tolerance
    max_iterations::Int         # Maximum iterations
    
    # Solver parameters
    method::Symbol              # Numerical method
    adaptive::Bool              # Use adaptive methods
    
    function NumericalParameters(r_min::T=1e-6, r_max::T=20.0, n_points::Int=1000,
                                abs_tol::T=1e-10, rel_tol::T=1e-8, 
                                max_iterations::Int=1000,
                                method::Symbol=:rk4, adaptive::Bool=true) where T<:Real
        @assert r_min > 0 "Minimum radius must be positive"
        @assert r_max > r_min "Maximum radius must be greater than minimum"
        @assert n_points > 0 "Number of points must be positive"
        @assert abs_tol > 0 "Absolute tolerance must be positive"
        @assert rel_tol > 0 "Relative tolerance must be positive"
        
        new{T}(r_min, r_max, n_points, abs_tol, rel_tol, max_iterations, method, adaptive)
    end
end

"""
    ComputationResult{T}

Container for storing computation results with metadata.
"""
struct ComputationResult{T}
    data::T                     # Main result data
    metadata::Dict{String,Any}  # Computation metadata
    success::Bool               # Computation success flag
    error_estimate::Float64     # Error estimate
    computation_time::Float64   # Elapsed time
    
    function ComputationResult(data::T, metadata::Dict{String,Any}=Dict{String,Any}(),
                              success::Bool=true, error_estimate::Float64=0.0,
                              computation_time::Float64=0.0) where T
        new{T}(data, metadata, success, error_estimate, computation_time)
    end
end

# ============================================================================
# Specialized Physics Types
# ============================================================================

"""
    ElectromagneticField{N, T<:Real}

Represents electromagnetic fields in N-dimensional space.
"""
struct ElectromagneticField{N, T<:Real}
    E::SVector{N,T}             # Electric field
    B::SVector{N,T}             # Magnetic field
    position::SVector{N,T}      # Field position
    time::T                     # Time
    
    function ElectromagneticField(E::SVector{N,T}, B::SVector{N,T}, 
                                 pos::SVector{N,T}, t::T) where {N,T<:Real}
        new{N,T}(E, B, pos, t)
    end
end

"""
    WavePacket{T<:Complex}

Represents a quantum wave packet with Gaussian envelope.
"""
struct WavePacket{T<:Complex}
    amplitude::T                # Peak amplitude
    center::Float64             # Spatial center
    width::Float64              # Spatial width (σ)
    momentum::Float64           # Central momentum
    phase::Float64              # Overall phase
    
    function WavePacket(amplitude::T, center::Float64, width::Float64,
                       momentum::Float64, phase::Float64=0.0) where T<:Complex
        @assert width > 0 "Width must be positive"
        new{T}(amplitude, center, width, momentum, phase)
    end
end

# ============================================================================
# Type Aliases for Convenience
# ============================================================================

# Common type aliases
const RealVector = Vector{Float64}
const ComplexVector = Vector{ComplexF64}
const RealMatrix = Matrix{Float64}
const ComplexMatrix = Matrix{ComplexF64}

# 3D vectors and matrices
const Vec3D = SVector{3, Float64}
const Mat3D = SMatrix{3, 3, Float64}

# Quantum state aliases
const Wavefunction1D = QuantumState{ComplexF64, 1}
const BoundState1D = BoundState{ComplexF64}
const ScatteringState1D = ScatteringState{ComplexF64}

# Classical system aliases
const Particle3D = ClassicalParticle{3, Float64}
const PhaseSpace3D = PhaseSpace{3, Float64}

# ============================================================================
# Constructor Convenience Functions
# ============================================================================

"""
    yukawa_potential(coupling, mass; units=:natural)

Convenience constructor for YukawaPotential.
"""
yukawa_potential(coupling, mass; units=:natural) = YukawaPotential(coupling, mass, units)

"""
    coulomb_potential(charge; units=:atomic)

Convenience constructor for CoulombPotential.
"""
coulomb_potential(charge; units=:atomic) = CoulombPotential(charge, units)

"""
    particle_3d(x, y, z, vx, vy, vz, mass; charge=0.0)

Convenience constructor for 3D classical particle.
"""
function particle_3d(x, y, z, vx, vy, vz, mass; charge=0.0)
    pos = SVector(x, y, z)
    vel = SVector(vx, vy, vz)
    return ClassicalParticle(pos, vel, mass, charge)
end

"""
    wave_packet_gaussian(center, width, momentum; amplitude=1.0, phase=0.0)

Convenience constructor for Gaussian wave packet.
"""
function wave_packet_gaussian(center, width, momentum; amplitude=1.0+0.0im, phase=0.0)
    return WavePacket(amplitude, center, width, momentum, phase)
end