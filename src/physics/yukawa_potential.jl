"""
# Yukawa Potential Physics Module

This module implements comprehensive solutions for the Yukawa potential problem,
including quantum mechanical bound states, scattering calculations, and classical
trajectory analysis.

## Mathematical Background

The Yukawa potential is given by:
```
V(r) = -g²/(4π) * exp(-μr)/r
```

Where:
- g is the coupling constant
- μ is the mass parameter (inverse range)
- r is the radial distance

This potential arises in:
- Nuclear physics (strong force mediated by mesons)
- Plasma physics (screened Coulomb interactions)
- Condensed matter (effective interactions in materials)

## Key Features

- Exact analytical solutions where available
- High-precision numerical methods for general cases
- Bound state calculations with eigenvalue solvers
- Scattering phase shifts and cross sections
- Classical trajectory integration
- Advanced visualization capabilities

## References

1. Yukawa, H. (1935). "On the Interaction of Elementary Particles"
2. Morse, P. M. & Feshbach, H. "Methods of Theoretical Physics"
3. Landau, L. D. & Lifshitz, E. M. "Quantum Mechanics"
"""

using LinearAlgebra
using SpecialFunctions
using QuadGK
using DifferentialEquations
using BenchmarkTools

# ============================================================================
# Core Yukawa Potential Functions
# ============================================================================

"""
    yukawa_potential(V::YukawaPotential, r)

Evaluate the Yukawa potential at distance r.

# Arguments
- `V::YukawaPotential`: Potential parameters
- `r`: Radial distance (scalar or array)

# Returns
- Potential energy V(r) = -g²/(4π) * exp(-μr)/r

# Examples
```julia
V = YukawaPotential(1.0, 1.0, :natural)
energy = yukawa_potential(V, 2.0)  # Evaluate at r = 2.0
```
"""
function yukawa_potential(V::YukawaPotential{T}, r) where T<:Real
    g, μ = V.coupling, V.mass
    
    # Handle r = 0 case (returns -∞ for Coulomb-like behavior)
    if iszero(r)
        return -Inf
    end
    
    # Yukawa potential: V(r) = -g²/(4π) * exp(-μr)/r
    prefactor = -g^2 / (4π)
    return prefactor * exp(-μ * r) / r
end

"""
    yukawa_force(V::YukawaPotential, r)

Calculate the force F(r) = -dV/dr for the Yukawa potential.

# Mathematical Form
F(r) = -g²/(4π) * exp(-μr) * (1/r² + μ/r)

# Arguments
- `V::YukawaPotential`: Potential parameters
- `r`: Radial distance

# Returns
- Force magnitude (positive for attractive force)
"""
function yukawa_force(V::YukawaPotential{T}, r) where T<:Real
    g, μ = V.coupling, V.mass
    
    if iszero(r)
        return Inf
    end
    
    # F(r) = -dV/dr = -g²/(4π) * exp(-μr) * (1/r² + μ/r)
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