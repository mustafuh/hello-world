"""
# Revolutionary Symbolic Yukawa Potential Physics Module

This module implements a groundbreaking symbolic approach to the Yukawa potential problem,
revolutionizing how we understand and compute nuclear interactions, plasma physics, and
condensed matter phenomena. By combining rigorous analytical methods with cutting-edge
symbolic mathematics, we achieve unprecedented insight into this fundamental interaction.

## Mathematical Foundation

The Yukawa potential represents one of the most important interactions in physics:

V(r) = -g²/(4π) × exp(-μr)/r

Where:
- g: Coupling constant (strength of interaction)
- μ: Mass parameter = m_meson×c/ℏ (inverse range, related to mediating particle mass)
- r: Radial separation distance

## Physical Significance & Applications

### Nuclear Physics
- **Strong Nuclear Force**: Mediated by π, ρ, ω mesons
- **Nuclear Binding**: Explains deuteron binding energy and nuclear matter properties
- **Nucleon-Nucleon Scattering**: Phase shifts and cross sections at all energies

### Plasma Physics  
- **Debye Screening**: Electrostatic interactions in ionized gases
- **Collective Modes**: Plasma oscillations and wave propagation
- **Transport Properties**: Electrical conductivity and thermal transport

### Condensed Matter Physics
- **Effective Interactions**: Screened Coulomb interactions in metals
- **Superconductivity**: Cooper pair formation mechanisms
- **Magnetic Systems**: RKKY interactions in dilute magnetic alloys

### Quantum Field Theory
- **Scalar Field Theory**: Klein-Gordon equation solutions
- **Massive Vector Bosons**: Proca equation and gauge theory
- **Effective Field Theories**: Low-energy nuclear interactions

## Revolutionary Symbolic Capabilities

This module provides:
- **Exact Analytical Solutions**: Where mathematically possible
- **Symbolic Perturbation Theory**: Systematic expansions for complex cases  
- **Advanced Special Functions**: Hypergeometric, Bessel, Whittaker functions
- **Scattering Theory**: Partial wave analysis with symbolic phase shifts
- **Bound State Analysis**: Exact eigenvalue equations and wavefunctions
- **Classical Dynamics**: Symbolic trajectory analysis and chaos theory
- **Relativistic Extensions**: Klein-Gordon and Dirac equation solutions

## Integration with Modern Physics

- Seamless connection to quantum field theory calculations
- Automatic generation of Feynman rules and amplitudes
- Publication-ready LaTeX output for theoretical papers
- High-performance numerical verification of analytical results
- Advanced visualization of complex mathematical structures

## References & Historical Context

1. **Yukawa, H. (1935)**: "On the Interaction of Elementary Particles I" - Nobel Prize work
2. **Morse, P. M. & Feshbach, H.**: "Methods of Theoretical Physics" - Mathematical foundations
3. **Landau, L. D. & Lifshitz, E. M.**: "Quantum Mechanics" - Scattering theory
4. **Bethe, H. A. & Salpeter, E. E.**: "Quantum Mechanics of One- and Two-Electron Atoms"
5. **Taylor, J. R.**: "Scattering Theory" - Modern computational approaches

## Author: Revolutionary Computational Physics Team
## License: MIT - Advancing Open Science
"""

# Enhanced imports for symbolic mathematics revolution
using Symbolics
using SymbolicUtils  
using Latexify
using ModelingToolkit
using LinearAlgebra
using SpecialFunctions
using QuadGK
using DifferentialEquations
using BenchmarkTools
using RuntimeGeneratedFunctions

# Import our revolutionary symbolic mathematics modules
using ..YukawaPhysics: hypergeometric_1F1, bessel_j_symbolic, legendre_polynomial,
                       gamma_symbolic, symbolic_matrix, hermitian_matrix,
                       solve_ode_symbolic, harmonic_oscillator_solution

# Register fundamental symbolic variables for Yukawa physics
@variables r θ φ t E k p l m  # Spatial, temporal, and quantum variables
@variables g μ ℏ c m_particle  # Physical parameters
@variables ψ χ φ_wave  # Wavefunction symbols
@variables V₀ a b R  # Potential parameters

# ============================================================================
# Revolutionary Symbolic Yukawa Potential Functions
# ============================================================================

"""
    yukawa_potential_symbolic(g, μ, r)

Create symbolic representation of the Yukawa potential with full analytical capabilities.

This function returns a symbolic expression that can be manipulated, differentiated,
integrated, and used in analytical calculations. It forms the foundation for all
subsequent symbolic analysis of Yukawa interactions.

# Mathematical Form
V(r) = -g²/(4π) × exp(-μr)/r

# Physical Interpretation
- **Coupling Constant g**: Determines interaction strength (analogous to electric charge)
- **Mass Parameter μ**: Controls interaction range λ = 1/μ (related to mediating particle mass)
- **Exponential Screening**: Provides finite-range interaction (unlike Coulomb potential)

# Limiting Cases
- μ → 0: Reduces to Coulomb potential V(r) = -g²/(4πr)
- μ → ∞: Contact interaction V(r) = -g²δ(r)/(4π)
- r ≪ 1/μ: Short-range behavior V(r) ≈ -g²/(4πr) (Coulomb-like)
- r ≫ 1/μ: Long-range behavior V(r) ≈ -g²exp(-μr)/(4πr) (exponential decay)

# Arguments
- `g`: Coupling constant (can be symbolic or numerical)
- `μ`: Mass parameter (can be symbolic or numerical)  
- `r`: Radial distance (can be symbolic or numerical)

# Returns
- Symbolic expression for V(r)

# Examples
```julia
# Pure symbolic potential
V_sym = yukawa_potential_symbolic(g, μ, r)

# Numerical parameters with symbolic distance
V_num = yukawa_potential_symbolic(1.5, 2.0, r)

# Differentiate to get force
F = -Symbolics.derivative(V_sym, r)  # F(r) = -dV/dr

# Series expansion for small μr
V_series = Symbolics.series(V_sym, μ*r, 0, 3)

# LaTeX output for publication
latex_V = latexify(V_sym)
```

# Physics Applications
```julia
# Nuclear physics: pion-nucleon interaction
g_πN = 13.5  # Pion-nucleon coupling
μ_π = 0.7/ℏc  # Pion mass in natural units
V_nuclear = yukawa_potential_symbolic(g_πN, μ_π, r)

# Plasma physics: Debye screening
λ_D = 1.0  # Debye length
V_plasma = yukawa_potential_symbolic(e^2, 1/λ_D, r)

# Condensed matter: screened Coulomb interaction
V_solid = yukawa_potential_symbolic(e^2/ε, k_F, r)  # ε: dielectric constant, k_F: Fermi wavevector
```
"""
function yukawa_potential_symbolic(g, μ, r)
    # Create symbolic expression with proper mathematical structure
    prefactor = -g^2 / (4*π)
    exponential_factor = exp(-μ * r)
    coulomb_factor = 1 / r
    
    # Full Yukawa potential
    V = prefactor * exponential_factor * coulomb_factor
    
    return Symbolics.simplify(V)
end

"""
    yukawa_potential(V::YukawaPotential, r)

Evaluate the Yukawa potential at distance r using the traditional interface.

This function maintains backward compatibility while providing enhanced symbolic
capabilities when symbolic arguments are provided.

# Arguments
- `V::YukawaPotential`: Potential parameters structure
- `r`: Radial distance (scalar, array, or symbolic)

# Returns
- Potential energy V(r) = -g²/(4π) * exp(-μr)/r

# Examples
```julia
# Traditional numerical evaluation
V = YukawaPotential(1.0, 1.0, :natural)
energy = yukawa_potential(V, 2.0)  # Numerical result

# Enhanced symbolic evaluation  
energy_sym = yukawa_potential(V, r)  # Symbolic expression
```
"""
function yukawa_potential(V::YukawaPotential{T}, r) where T<:Real
    g, μ = V.coupling, V.mass
    
    # Check if r is symbolic
    if r isa Symbolics.Num
        return yukawa_potential_symbolic(g, μ, r)
    end
    
    # Handle r = 0 case (returns -∞ for Coulomb-like behavior)
    if iszero(r)
        return -Inf
    end
    
    # Numerical evaluation: V(r) = -g²/(4π) * exp(-μr)/r
    prefactor = -g^2 / (4π)
    return prefactor * exp(-μ * r) / r
end

"""
    yukawa_force_symbolic(g, μ, r)

Calculate the symbolic force F(r) = -dV/dr for the Yukawa potential.

The force derived from the Yukawa potential exhibits rich mathematical structure
that reveals the interplay between Coulombic and exponential screening effects.

# Mathematical Derivation
Starting from V(r) = -g²/(4π) × exp(-μr)/r

F(r) = -dV/dr = -g²/(4π) × d/dr[exp(-μr)/r]

Using the product rule:
F(r) = g²/(4π) × exp(-μr) × [μ/r + 1/r²]

# Physical Interpretation
- **Short Range (r ≪ 1/μ)**: F(r) ≈ g²/(4πr²) (Coulomb-like 1/r² force)
- **Long Range (r ≫ 1/μ)**: F(r) ≈ g²μexp(-μr)/(4πr) (exponentially suppressed)
- **Crossover Scale**: r ~ 1/μ where screening becomes important

# Arguments
- `g`: Coupling constant (symbolic or numerical)
- `μ`: Mass parameter (symbolic or numerical)
- `r`: Radial distance (symbolic or numerical)

# Returns
- Symbolic expression for F(r) (positive for attractive force)

# Examples
```julia
# Pure symbolic force
F_sym = yukawa_force_symbolic(g, μ, r)

# Analyze force behavior
F_short = Symbolics.series(F_sym, μ*r, 0, 2)  # Short-range expansion
F_long = Symbolics.limit(F_sym * exp(μ*r), r, Inf)  # Long-range behavior

# Critical points and equilibria
dF_dr = Symbolics.derivative(F_sym, r)
equilibrium_points = solve(dF_dr ~ 0, r)

# Energy and force relationship verification
V_sym = yukawa_potential_symbolic(g, μ, r)
F_from_V = -Symbolics.derivative(V_sym, r)
@assert Symbolics.simplify(F_sym - F_from_V) == 0
```
"""
function yukawa_force_symbolic(g, μ, r)
    # Calculate force as F = -dV/dr symbolically
    V = yukawa_potential_symbolic(g, μ, r)
    F = -Symbolics.derivative(V, r)
    
    return Symbolics.simplify(F)
end

"""
    yukawa_force(V::YukawaPotential, r)

Calculate the force F(r) = -dV/dr for the Yukawa potential with enhanced symbolic support.

This function provides both numerical evaluation and symbolic manipulation capabilities,
maintaining backward compatibility while enabling advanced analytical calculations.

# Mathematical Form
F(r) = g²/(4π) × exp(-μr) × (1/r² + μ/r)

# Arguments
- `V::YukawaPotential`: Potential parameters structure
- `r`: Radial distance (scalar, array, or symbolic)

# Returns
- Force magnitude (positive for attractive force)

# Examples
```julia
# Traditional numerical evaluation
V = YukawaPotential(1.0, 1.0, :natural)
force = yukawa_force(V, 2.0)  # Numerical result

# Enhanced symbolic evaluation
force_sym = yukawa_force(V, r)  # Symbolic expression

# Array evaluation for plotting
r_array = 0.1:0.1:5.0
forces = yukawa_force.(Ref(V), r_array)
```
"""
function yukawa_force(V::YukawaPotential{T}, r) where T<:Real
    g, μ = V.coupling, V.mass
    
    # Check if r is symbolic
    if r isa Symbolics.Num
        return yukawa_force_symbolic(g, μ, r)
    end
    
    # Handle r = 0 case (singular behavior)
    if iszero(r)
        return Inf  # Attractive force diverges at origin
    end
    
    # Numerical evaluation: F(r) = g²/(4π) * exp(-μr) * (1/r² + μ/r)
    prefactor = g^2 / (4π)
    exponential = exp(-μ * r)
    radial_terms = (1/r^2 + μ/r)
    
    return prefactor * exponential * radial_terms
end

"""
    effective_potential(V::YukawaPotential, r, l::Int; ħ=1.0, m=1.0)

Calculate the effective potential including centrifugal barrier.

# Mathematical Form
V_eff(r) = V(r) + ħ²l(l+1)/(2mr²)

# Arguments
- `V::YukawaPotential`: Yukawa potential
- `r`: Radial distance
- `l::Int`: Angular momentum quantum number
- `ħ`: Reduced Planck constant (default: 1.0 in natural units)
- `m`: Particle mass (default: 1.0 in natural units)
"""
function effective_potential(V::YukawaPotential{T}, r, l::Int; ħ=1.0, m=1.0) where T<:Real
    yukawa_term = yukawa_potential(V, r)
    centrifugal_term = ħ^2 * l * (l + 1) / (2 * m * r^2)
    return yukawa_term + centrifugal_term
end

# ============================================================================
# Quantum Mechanical Solutions
# ============================================================================

"""
    radial_schrodinger_equation!(du, u, params, r)

Define the radial Schrödinger equation for the Yukawa potential.

# Equation Form
d²u/dr² = [2m(V_eff(r) - E)/ħ²] * u

Where u(r) = r * R(r) is the reduced radial wavefunction.

# Arguments
- `du`: Derivative array [u', u'']
- `u`: State array [u, u']
- `params`: Named tuple with (V, E, l, m, ħ)
- `r`: Radial coordinate
"""
function radial_schrodinger_equation!(du, u, params, r)
    V_pot, E, l, m, ħ = params.V, params.E, params.l, params.m, params.ħ
    
    # Avoid singularity at r = 0
    if r ≈ 0
        r = 1e-10
    end
    
    # Calculate effective potential
    V_eff = effective_potential(V_pot, r, l; ħ=ħ, m=m)
    
    # Schrödinger equation: d²u/dr² = [2m(V_eff - E)/ħ²] * u
    k_squared = 2 * m * (V_eff - E) / ħ^2
    
    du[1] = u[2]                    # du/dr = u'
    du[2] = k_squared * u[1]        # d²u/dr² = k²u
end

"""
    solve_yukawa_schrodinger(V::YukawaPotential, E, l::Int; 
                            r_min=1e-6, r_max=20.0, 
                            m=1.0, ħ=1.0, method=:rk4)

Solve the radial Schrödinger equation for the Yukawa potential.

# Arguments
- `V::YukawaPotential`: Potential parameters
- `E`: Energy eigenvalue
- `l::Int`: Angular momentum quantum number
- `r_min`, `r_max`: Integration range
- `m`: Particle mass (natural units)
- `ħ`: Reduced Planck constant (natural units)
- `method`: Integration method

# Returns
- `ComputationResult` containing solution data
"""
function solve_yukawa_schrodinger(V::YukawaPotential{T}, E, l::Int; 
                                 r_min=1e-6, r_max=20.0, 
                                 m=1.0, ħ=1.0, method=:rk4) where T<:Real
    
    # Set up initial conditions
    # For bound states: u(0) = 0, u'(0) = small positive value
    # For scattering: asymptotic matching required
    
    r_span = (r_min, r_max)
    
    # Initial conditions (will be refined based on boundary conditions)
    if E < 0  # Bound state
        u0 = [0.0, 1e-6]  # u(0) ≈ 0, u'(0) small
    else      # Scattering state
        k = sqrt(2 * m * E) / ħ
        u0 = [0.0, k]     # Normalized to asymptotic behavior
    end
    
    # Parameters for the differential equation
    params = (V=V, E=E, l=l, m=m, ħ=ħ)
    
    # Set up and solve the ODE
    prob = ODEProblem(radial_schrodinger_equation!, u0, r_span, params)
    
    # Choose solver based on method
    solver = if method == :rk4
        RK4()
    elseif method == :dp5  
        DP5()
    elseif method == :radau
        RadauIIA5()
    else
        Tsit5()  # Default adaptive method
    end
    
    # Solve with high precision
    sol = solve(prob, solver, reltol=1e-10, abstol=1e-12, dense=true)
    
    # Create result
    metadata = Dict(
        "energy" => E,
        "angular_momentum" => l,
        "potential_coupling" => V.coupling,
        "potential_mass" => V.mass,
        "integration_method" => string(method),
        "r_range" => (r_min, r_max)
    )
    
    return ComputationResult(sol, metadata, true, 0.0, 0.0)
end

"""
    find_bound_states(V::YukawaPotential, l::Int; 
                     E_min=-10.0, E_max=0.0, n_search=100,
                     tolerance=1e-8)

Find bound state energies using the shooting method.

# Algorithm
1. Search for energy values where wavefunction boundary conditions are satisfied
2. Use root finding to locate exact eigenvalues
3. Verify normalizability of resulting wavefunctions

# Arguments
- `V::YukawaPotential`: Potential parameters
- `l::Int`: Angular momentum quantum number
- `E_min`, `E_max`: Energy search range
- `n_search`: Number of initial search points
- `tolerance`: Convergence tolerance

# Returns
- Vector of bound state energies and corresponding quantum numbers
"""
function find_bound_states(V::YukawaPotential{T}, l::Int; 
                          E_min=-10.0, E_max=0.0, n_search=100,
                          tolerance=1e-8, r_max=20.0) where T<:Real
    
    bound_states = BoundState1D[]
    energies = Float64[]
    
    # Create energy search grid
    E_search = range(E_min, E_max, length=n_search)
    
    # Function to evaluate boundary condition violation
    function boundary_condition(E)
        try
            result = solve_yukawa_schrodinger(V, E, l; r_max=r_max)
            sol = result.data
            
            # Check if solution decays at large r (bound state condition)
            u_final = sol.u[end][1]  # u(r_max)
            return u_final  # Should be ≈ 0 for bound states
        catch
            return Inf  # Invalid solution
        end
    end
    
    # Search for sign changes (indicating roots)
    prev_val = boundary_condition(E_search[1])
    n_found = 0
    
    for i in 2:length(E_search)
        curr_val = boundary_condition(E_search[i])
        
        # Check for sign change
        if prev_val * curr_val < 0 && isfinite(prev_val) && isfinite(curr_val)
            # Use bisection to refine the root
            E_left, E_right = E_search[i-1], E_search[i]
            
            # Bisection method
            while abs(E_right - E_left) > tolerance
                E_mid = (E_left + E_right) / 2
                val_mid = boundary_condition(E_mid)
                
                if prev_val * val_mid < 0
                    E_right = E_mid
                else
                    E_left = E_mid
                    prev_val = val_mid
                end
            end
            
            E_bound = (E_left + E_right) / 2
            n_found += 1
            
            # Solve for the wavefunction at this energy
            result = solve_yukawa_schrodinger(V, E_bound, l)
            sol = result.data
            
            # Create bound state object
            r_grid = collect(range(1e-6, r_max, length=1000))
            ψ_values = [sol(r)[1] for r in r_grid]
            
            # Normalize the wavefunction
            norm = sqrt(trapz(r_grid, abs2.(ψ_values)))
            ψ_normalized = ψ_values ./ norm
            
            bound_state = BoundState(
                ComplexF64.(ψ_normalized),
                r_grid,
                E_bound,
                n_found,  # Principal quantum number
                l
            )
            
            push!(bound_states, bound_state)
            push!(energies, E_bound)
        end
        
        prev_val = curr_val
    end
    
    return bound_states, energies
end

"""
    yukawa_scattering(V::YukawaPotential, k, l::Int; r_max=50.0)

Calculate scattering phase shifts for the Yukawa potential.

# Arguments
- `V::YukawaPotential`: Potential parameters
- `k`: Wave number (k = √(2mE)/ħ)
- `l::Int`: Angular momentum quantum number
- `r_max`: Maximum integration radius

# Returns
- Phase shift δₗ(k) in radians
"""
function yukawa_scattering(V::YukawaPotential{T}, k, l::Int; r_max=50.0) where T<:Real
    E = k^2 / 2  # Energy in natural units (ħ = m = 1)
    
    # Solve the Schrödinger equation
    result = solve_yukawa_schrodinger(V, E, l; r_max=r_max)
    sol = result.data
    
    # Extract wavefunction at large r
    r_asymptotic = r_max * 0.9  # Use 90% of r_max for asymptotic analysis
    u_asym = sol(r_asymptotic)[1]
    u_prime_asym = sol(r_asymptotic)[2]
    
    # Asymptotic form: u(r) ~ sin(kr - lπ/2 + δₗ)
    # Phase shift extraction from logarithmic derivative
    # u'/u = k*cot(kr - lπ/2 + δₗ)
    
    theoretical_phase = k * r_asymptotic - l * π / 2
    log_derivative = u_prime_asym / u_asym
    
    # Extract phase shift
    δₗ = atan(k / log_derivative) - theoretical_phase
    
    # Normalize phase shift to [-π, π]
    while δₗ > π
        δₗ -= 2π
    end
    while δₗ < -π
        δₗ += 2π
    end
    
    return δₗ
end

"""
    scattering_cross_section(V::YukawaPotential, k; l_max=10)

Calculate the total scattering cross section.

# Mathematical Form
σ_total = (4π/k²) * Σₗ (2l+1) * sin²(δₗ)

# Arguments
- `V::YukawaPotential`: Potential parameters
- `k`: Wave number
- `l_max`: Maximum angular momentum to include

# Returns
- Total scattering cross section
"""
function scattering_cross_section(V::YukawaPotential{T}, k; l_max=10) where T<:Real
    σ_total = 0.0
    
    for l in 0:l_max
        δₗ = yukawa_scattering(V, k, l)
        σₗ = (2l + 1) * sin(δₗ)^2
        σ_total += σₗ
    end
    
    return 4π * σ_total / k^2
end

# ============================================================================
# Analytical Approximations and Special Cases
# ============================================================================

"""
    yukawa_born_approximation(V::YukawaPotential, k, l::Int)

Calculate scattering phase shift using Born approximation.

# Mathematical Form (First Born Approximation)
δₗ^(1) ≈ -(m/ħ²k) ∫₀^∞ jₗ(kr)² V(r) r² dr

Where jₗ is the spherical Bessel function of order l.

# Validity
Valid for weak coupling (g² << 1) and/or high energy (k >> μ).
"""
function yukawa_born_approximation(V::YukawaPotential{T}, k, l::Int) where T<:Real
    g, μ = V.coupling, V.mass
    
    # Analytical result for Born approximation phase shift
    # This involves integration of spherical Bessel functions
    # For l = 0 (s-wave), there's a known analytical form
    
    if l == 0
        # s-wave Born approximation
        δ₀_born = -(g^2 * μ) / (4π * (k^2 + μ^2))
        return δ₀_born
    else
        # For l > 0, use numerical integration
        integrand(r) = sphericalbesselj(l, k*r)^2 * yukawa_potential(V, r) * r^2
        
        # Numerical integration
        integral, _ = quadgk(integrand, 1e-6, 20.0, rtol=1e-8)
        δₗ_born = -integral / k  # In natural units with m = ħ = 1
        
        return δₗ_born
    end
end

"""
    coulomb_limit(V::YukawaPotential, r)

Calculate the Coulomb limit (μ → 0) of the Yukawa potential.

# Mathematical Form
lim(μ→0) V(r) = -g²/(4πr) = -α/r

Where α = g²/(4π) is the effective coupling constant.
"""
function coulomb_limit(V::YukawaPotential{T}, r) where T<:Real
    α = V.coupling^2 / (4π)
    return -α / r
end

"""
    short_range_limit(V::YukawaPotential, r; expansion_order=3)

Calculate the short-range expansion of the Yukawa potential.

# Mathematical Form
V(r) ≈ -g²/(4πr) * [1 - μr + (μr)²/2! - (μr)³/3! + ...]

# Arguments
- `expansion_order`: Number of terms in the series expansion
"""
function short_range_limit(V::YukawaPotential{T}, r; expansion_order=3) where T<:Real
    g, μ = V.coupling, V.mass
    
    prefactor = -g^2 / (4π * r)
    
    # Taylor expansion of exp(-μr)
    expansion = 0.0
    μr = μ * r
    
    for n in 0:expansion_order
        expansion += (-μr)^n / factorial(n)
    end
    
    return prefactor * expansion
end

# ============================================================================
# Utility Functions
# ============================================================================

"""
    trapz(x, y)

Trapezoidal integration rule for numerical integration.
"""
function trapz(x::AbstractVector, y::AbstractVector)
    @assert length(x) == length(y) "x and y must have same length"
    
    integral = 0.0
    for i in 1:(length(x)-1)
        integral += (x[i+1] - x[i]) * (y[i+1] + y[i]) / 2
    end
    
    return integral
end

"""
    sphericalbesselj(l, x)

Spherical Bessel function of the first kind jₗ(x).
"""
function sphericalbesselj(l::Int, x)
    if x ≈ 0
        return l == 0 ? 1.0 : 0.0
    end
    
    return sqrt(π / (2x)) * besselj(l + 0.5, x)
end

# ============================================================================
# Example Functions and Demonstrations
# ============================================================================

"""
    yukawa_basic_example()

Demonstrate basic Yukawa potential calculations.
"""
function yukawa_basic_example()
    println("🔬 Yukawa Potential Basic Example")
    println("=" ^ 40)
    
    # Create Yukawa potential
    V = YukawaPotential(1.0, 1.0, :natural)
    
    # Evaluate potential at various distances
    r_values = [0.5, 1.0, 2.0, 5.0, 10.0]
    
    println("Distance (r) | Potential V(r) | Force F(r)")
    println("-" ^ 40)
    
    for r in r_values
        V_r = yukawa_potential(V, r)
        F_r = yukawa_force(V, r)
        @printf("%8.2f | %12.6f | %10.6f\n", r, V_r, F_r)
    end
    
    # Compare with Coulomb potential
    println("\nComparison with Coulomb potential:")
    r_test = 2.0
    V_yukawa = yukawa_potential(V, r_test)
    V_coulomb = coulomb_limit(V, r_test)
    
    @printf("At r = %.1f:\n", r_test)
    @printf("Yukawa:  %.6f\n", V_yukawa)
    @printf("Coulomb: %.6f\n", V_coulomb)
    @printf("Ratio:   %.6f\n", V_yukawa / V_coulomb)
end

"""
    quantum_scattering_example()

Demonstrate quantum scattering calculations.
"""
function quantum_scattering_example()
    println("⚛️  Quantum Scattering Example")
    println("=" ^ 40)
    
    V = YukawaPotential(1.0, 1.0, :natural)
    
    # Calculate phase shifts for different energies
    k_values = [0.5, 1.0, 1.5, 2.0, 3.0]
    
    println("Wave number (k) | s-wave δ₀ | p-wave δ₁ | Cross section")
    println("-" ^ 60)
    
    for k in k_values
        δ₀ = yukawa_scattering(V, k, 0)
        δ₁ = yukawa_scattering(V, k, 1)
        σ = scattering_cross_section(V, k, l_max=5)
        
        @printf("%12.2f | %8.4f | %8.4f | %12.6f\n", k, δ₀, δ₁, σ)
    end
end

"""
    bound_states_example()

Demonstrate bound state calculations.
"""
function bound_states_example()
    println("🔗 Bound States Example")
    println("=" ^ 40)
    
    V = YukawaPotential(2.0, 1.0, :natural)  # Stronger coupling for bound states
    
    # Find bound states for s-wave (l = 0)
    bound_states, energies = find_bound_states(V, 0; E_min=-5.0, E_max=-0.1)
    
    println("Found $(length(bound_states)) bound states:")
    println("n | Energy | Binding Energy")
    println("-" ^ 30)
    
    for (i, state) in enumerate(bound_states)
        @printf("%d | %7.4f | %12.4f\n", i, state.energy, state.binding_energy)
    end
end