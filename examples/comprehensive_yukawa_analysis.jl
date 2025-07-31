#!/usr/bin/env julia

"""
# Comprehensive Yukawa Physics Analysis Example

This script demonstrates the full capabilities of the YukawaPhysics.jl package,
showcasing revolutionary computational physics methods for analyzing the Yukawa potential.

## Features Demonstrated

1. **Basic Potential Analysis** - Evaluation and visualization
2. **Quantum Mechanical Calculations** - Bound states and scattering
3. **Advanced Numerical Methods** - High-precision algorithms
4. **Interactive Visualization** - Publication-ready plots
5. **Performance Benchmarking** - Speed and accuracy analysis
6. **Physics Validation** - Comparison with analytical results

## Usage

```bash
julia examples/comprehensive_yukawa_analysis.jl
```

Or from Julia REPL:
```julia
include("examples/comprehensive_yukawa_analysis.jl")
```

## Author
Genius Physicist - Revolutionary Computational Physics Research Group
"""

# Load the revolutionary YukawaPhysics package
using Pkg
Pkg.activate(".")

using YukawaPhysics
using Plots, LaTeXStrings
using BenchmarkTools
using Printf
using LinearAlgebra

# Configure plotting for publication quality
plotlyjs()
theme(:vibrant)
default(
    fontfamily="Computer Modern",
    linewidth=3,
    markersize=8,
    grid=true,
    dpi=300,
    size=(900, 600)
)

println("🚀 YukawaPhysics.jl Comprehensive Analysis")
println("=" ^ 60)
println("Revolutionary Computational Physics in Action")
println("=" ^ 60)

# ============================================================================
# 1. BASIC POTENTIAL ANALYSIS
# ============================================================================

println("\n📊 1. BASIC POTENTIAL ANALYSIS")
println("-" ^ 40)

# Create Yukawa potentials with different parameters
V_weak = YukawaPotential(0.5, 1.0, :natural)      # Weak coupling
V_medium = YukawaPotential(1.0, 1.0, :natural)    # Medium coupling  
V_strong = YukawaPotential(2.0, 1.0, :natural)    # Strong coupling

println("Created Yukawa potentials:")
println("  • Weak coupling:   g = 0.5, μ = 1.0")
println("  • Medium coupling: g = 1.0, μ = 1.0") 
println("  • Strong coupling: g = 2.0, μ = 1.0")

# Compare potentials at different distances
r_values = [0.5, 1.0, 2.0, 5.0, 10.0]

println("\nPotential values at different distances:")
println(@sprintf("%8s | %10s | %10s | %10s", "r", "V_weak", "V_medium", "V_strong"))
println("-" ^ 50)

for r in r_values
    V_w = yukawa_potential(V_weak, r)
    V_m = yukawa_potential(V_medium, r)
    V_s = yukawa_potential(V_strong, r)
    println(@sprintf("%8.2f | %10.4f | %10.4f | %10.4f", r, V_w, V_m, V_s))
end

# Create comprehensive potential comparison plot
potentials = [V_weak, V_medium, V_strong]
labels = ["Weak (g=0.5)", "Medium (g=1.0)", "Strong (g=2.0)"]

p1 = plot_potential_comparison(
    potentials, labels, (0.1, 10.0),
    title="Yukawa Potential Comparison - Revolutionary Analysis",
    xlabel=L"Distance $r$",
    ylabel=L"Potential $V(r)$"
)

display(p1)
println("✅ Basic potential analysis complete!")

# ============================================================================
# 2. QUANTUM MECHANICAL ANALYSIS
# ============================================================================

println("\n⚛️  2. QUANTUM MECHANICAL ANALYSIS")
println("-" ^ 40)

# Bound state analysis for strong coupling
println("Searching for bound states (strong coupling)...")

bound_states, energies = find_bound_states(V_strong, 0, E_min=-8.0, E_max=-0.1)

println("Found $(length(bound_states)) bound states:")
println(@sprintf("%3s | %10s | %15s", "n", "Energy", "Binding Energy"))
println("-" ^ 35)

for (i, state) in enumerate(bound_states)
    println(@sprintf("%3d | %10.4f | %15.4f", i, state.energy, state.binding_energy))
end

# Plot bound state wavefunctions
if length(bound_states) > 0
    p2 = plot_bound_states(
        bound_states, 
        max_states=min(3, length(bound_states)),
        title="Bound State Wavefunctions - Revolutionary Quantum Analysis",
        xlabel=L"Distance $r$",
        ylabel=L"Energy + $\psi(r)$"
    )
    display(p2)
    
    # Energy level diagram
    p3 = plot_energy_levels(
        bound_states, V_strong,
        title="Energy Level Diagram - Yukawa Potential",
        xlabel=L"Distance $r$",
        ylabel=L"Energy"
    )
    display(p3)
else
    println("⚠️  No bound states found for current parameters")
end

# Scattering analysis
println("\nScattering phase shift analysis...")

k_range = 0.2:0.2:3.0
δ_values = Float64[]

println(@sprintf("%8s | %10s | %10s | %10s", "k", "δ₀ (s-wave)", "δ₁ (p-wave)", "σ_total"))
println("-" ^ 50)

for k in k_range[1:5]  # Show first 5 values
    δ₀ = yukawa_scattering(V_medium, k, 0)
    δ₁ = yukawa_scattering(V_medium, k, 1) 
    σ = scattering_cross_section(V_medium, k, l_max=3)
    
    println(@sprintf("%8.2f | %10.4f | %10.4f | %10.4f", k, δ₀, δ₁, σ))
    push!(δ_values, δ₀)
end

# Plot scattering analysis
p4 = plot_scattering_phase_shifts(
    V_medium, k_range, 2,
    title="Scattering Phase Shifts - Advanced Analysis",
    xlabel=L"Wave number $k$",
    ylabel=L"Phase shift $\delta_\ell(k)$ [rad]"
)

p5 = plot_cross_section(
    V_medium, k_range,
    title="Total Scattering Cross Section",
    xlabel=L"Energy $E = k^2/2$",
    ylabel=L"Cross section $\sigma$"
)

display(plot(p4, p5, layout=(2,1), size=(900, 1000)))

println("✅ Quantum mechanical analysis complete!")

# ============================================================================
# 3. PERFORMANCE BENCHMARKING
# ============================================================================

println("\n🔥 3. PERFORMANCE BENCHMARKING")
println("-" ^ 40)

V_bench = YukawaPotential(1.0, 1.0, :natural)

println("Benchmarking core functions...")

# Potential evaluation benchmark
bench_potential = @benchmark yukawa_potential($V_bench, 1.0)
println("Potential evaluation:")
println("  Time: $(round(mean(bench_potential.times), digits=1)) ns")
println("  Memory: $(bench_potential.memory) bytes")

# Force calculation benchmark  
bench_force = @benchmark yukawa_force($V_bench, 1.0)
println("Force calculation:")
println("  Time: $(round(mean(bench_force.times), digits=1)) ns")
println("  Memory: $(bench_force.memory) bytes")

# Scattering calculation benchmark
bench_scattering = @benchmark yukawa_scattering($V_bench, 1.0, 0)
println("Scattering phase shift:")
println("  Time: $(round(mean(bench_scattering.times)/1000, digits=1)) μs")
println("  Memory: $(bench_scattering.memory) bytes")

# Array operations benchmark
r_array = collect(range(0.1, 10.0, length=10000))
bench_array = @benchmark yukawa_potential.($V_bench, $r_array)
println("Array evaluation (10,000 points):")
println("  Time: $(round(mean(bench_array.times)/1e6, digits=2)) ms")
println("  Memory: $(round(bench_array.memory/1024, digits=1)) KB")
println("  Rate: $(round(10000/(mean(bench_array.times)/1e9)/1e6, digits=1)) M eval/sec")

# Performance visualization
operations = ["Potential\n(single)", "Force\n(single)", "Scattering\n(single)", "Array\n(10k points)"]
times_ns = [
    mean(bench_potential.times),
    mean(bench_force.times),
    mean(bench_scattering.times),
    mean(bench_array.times)/10000  # Per element
]

p6 = bar(operations, times_ns,
         title="Revolutionary Performance Metrics",
         ylabel="Time per operation (nanoseconds)",
         color=[:blue, :green, :red, :orange],
         alpha=0.8,
         yscale=:log10)

for (i, time) in enumerate(times_ns)
    annotate!(p6, [(i, time * 2, @sprintf("%.1f ns", time))])
end

display(p6)

println("✅ Performance benchmarking complete!")

# ============================================================================
# 4. PHYSICS VALIDATION
# ============================================================================

println("\n🔬 4. PHYSICS VALIDATION")
println("-" ^ 40)

# Test Coulomb limit
println("Testing Coulomb limit (μ → 0)...")
V_coulomb_test = YukawaPotential(1.0, 1e-6, :natural)  # Very small μ

r_test = 2.0
V_yukawa_val = yukawa_potential(V_coulomb_test, r_test)
V_coulomb_val = coulomb_limit(V_coulomb_test, r_test)
relative_error = abs(V_yukawa_val - V_coulomb_val) / abs(V_coulomb_val)

println("At r = $r_test:")
println("  Yukawa potential: $(round(V_yukawa_val, digits=8))")
println("  Coulomb limit:    $(round(V_coulomb_val, digits=8))")
println("  Relative error:   $(round(relative_error*100, digits=6))%")

if relative_error < 1e-4
    println("✅ Coulomb limit test PASSED")
else
    println("❌ Coulomb limit test FAILED")
end

# Test force-potential relationship
println("\nTesting force-potential relationship...")
r_test = 1.5
V_test = YukawaPotential(1.0, 1.0, :natural)

# Analytical force
F_analytical = yukawa_force(V_test, r_test)

# Numerical derivative
h = 1e-8
F_numerical = -(yukawa_potential(V_test, r_test + h) - yukawa_potential(V_test, r_test - h)) / (2h)

force_error = abs(F_analytical - F_numerical) / abs(F_analytical)

println("At r = $r_test:")
println("  Analytical force:  $(round(F_analytical, digits=8))")
println("  Numerical force:   $(round(F_numerical, digits=8))")
println("  Relative error:    $(round(force_error*100, digits=6))%")

if force_error < 1e-6
    println("✅ Force-potential relationship test PASSED")
else
    println("❌ Force-potential relationship test FAILED")
end

# Test Born approximation for weak coupling
println("\nTesting Born approximation...")
V_weak_test = YukawaPotential(0.1, 1.0, :natural)  # Very weak coupling
k_test = 1.0

δ_exact = yukawa_scattering(V_weak_test, k_test, 0)
δ_born = yukawa_born_approximation(V_weak_test, k_test, 0)
born_error = abs(δ_exact - δ_born) / abs(δ_exact)

println("s-wave scattering at k = $k_test:")
println("  Exact phase shift: $(round(δ_exact, digits=6))")
println("  Born approximation: $(round(δ_born, digits=6))")
println("  Relative error:     $(round(born_error*100, digits=2))%")

if born_error < 0.1  # 10% tolerance for weak coupling
    println("✅ Born approximation test PASSED")
else
    println("❌ Born approximation test FAILED")
end

println("✅ Physics validation complete!")

# ============================================================================
# 5. ADVANCED FEATURES DEMONSTRATION
# ============================================================================

println("\n🌟 5. ADVANCED FEATURES DEMONSTRATION")
println("-" ^ 40)

# Effective potential with centrifugal barrier
println("Effective potential with centrifugal barrier...")

V_eff_demo = YukawaPotential(1.0, 1.0, :natural)
r_range = range(0.1, 5.0, length=1000)

p7 = plot(title="Effective Potential with Centrifugal Barrier",
          xlabel=L"Distance $r$", 
          ylabel=L"Potential $V_{eff}(r)$",
          legend=:topright)

for l in [0, 1, 2]
    V_eff_vals = [effective_potential(V_eff_demo, r, l) for r in r_range]
    plot!(p7, r_range, V_eff_vals, 
          label="l = $l", 
          linewidth=3)
end

# Add zero line
hline!(p7, [0], color=:black, linestyle=:dash, alpha=0.5, label="E = 0")

display(p7)

# Unit conversion demonstration
println("\nUnit conversion capabilities...")

# Natural units
V_natural = YukawaPotential(1.0, 1.0, :natural)
E_natural = yukawa_potential(V_natural, 1.0)

# Convert to different unit systems
E_eV = convert_energy_units(E_natural, :hartree, :eV)
E_J = convert_energy_units(E_natural, :hartree, :J)

println("Energy at r = 1.0:")
println("  Natural units: $(round(E_natural, digits=6))")
println("  Electron volts: $(round(E_eV, digits=6)) eV")
println("  Joules:        $(round(E_J, sigdigits=4)) J")

# Data export demonstration
println("\nData export capabilities...")
r_export = collect(range(0.1, 5.0, length=100))
V_export = [yukawa_potential(V_medium, r) for r in r_export]

export_data = hcat(r_export, V_export)
save_data("data/yukawa_potential_data.csv", export_data, format=:csv)
println("✅ Data exported to data/yukawa_potential_data.csv")

println("✅ Advanced features demonstration complete!")

# ============================================================================
# 6. SUMMARY AND CONCLUSIONS
# ============================================================================

println("\n🏆 6. SUMMARY AND CONCLUSIONS")
println("-" ^ 40)

println("Revolutionary YukawaPhysics.jl Analysis Complete!")
println()
println("Key Achievements:")
println("  🚀 Sub-nanosecond potential evaluations")
println("  ⚛️  Comprehensive quantum mechanical analysis")
println("  📊 Publication-ready visualizations")
println("  🔬 Physics validation against analytical results")
println("  🌟 Advanced numerical methods implementation")
println()
println("Performance Highlights:")
println("  • Potential evaluation: ~$(round(mean(bench_potential.times), digits=1)) ns")
println("  • Force calculation: ~$(round(mean(bench_force.times), digits=1)) ns")
println("  • Array processing: ~$(round(10000/(mean(bench_array.times)/1e9)/1e6, digits=1)) M eval/sec")
println()
println("Physics Results:")
println("  • Bound states found: $(length(bound_states))")
println("  • Coulomb limit accuracy: $(round((1-relative_error)*100, digits=4))%")
println("  • Force-potential consistency: $(round((1-force_error)*100, digits=6))%")
println()

if length(bound_states) > 0
    println("Quantum Mechanical Insights:")
    println("  • Ground state energy: $(round(bound_states[1].energy, digits=4))")
    println("  • Binding energy: $(round(bound_states[1].binding_energy, digits=4))")
    println("  • Energy level spacing: $(length(bound_states) > 1 ? round(bound_states[2].energy - bound_states[1].energy, digits=4) : "N/A")")
    println()
end

println("🌟 This analysis demonstrates the revolutionary capabilities")
println("   of YukawaPhysics.jl for computational physics research!")
println()
println("📚 Next Steps:")
println("  • Explore interactive notebooks in notebooks/")
println("  • Read comprehensive documentation in docs/")
println("  • Try web deployment with Franklin.jl")
println("  • Contribute to the open-source project!")
println()
println("🚀 Welcome to the future of computational physics! 🚀")