"""
# YukawaPhysics.jl

A comprehensive Julia package for computational physics focusing on the Yukawa potential
and advanced mathematical algorithms for physics simulations.

## Overview

This package provides:
- Yukawa potential solvers with multiple numerical methods
- Advanced quantum mechanical calculations
- Interactive visualization tools
- Publication-ready mathematical computations
- Web deployment capabilities for physics simulations

## Author
Physicist pursuing revolutionary computational physics methodologies

## License
MIT License
"""
module YukawaPhysics

# Standard library imports
using LinearAlgebra
using Printf
using Random

# Symbolic Mathematics - Revolutionary Computational Physics Core
using Symbolics
using SymbolicUtils
using Latexify
using SymbolicNumericIntegration

# Scientific computing and modeling
using DifferentialEquations
using ModelingToolkit
using SpecialFunctions
using QuadGK
using FFTW
using StaticArrays
using RuntimeGeneratedFunctions

# Units and constants
using Unitful
using UnitfulAstro
using UnitfulLatexify
using PhysicalConstants.CODATA2018

# Visualization and plotting
using Plots
using PlotlyJS
using Colors
using ColorSchemes
using LaTeXStrings

# Statistics and distributions
using StatsBase
using Distributions

# Advanced symbolic mathematics
using AbstractAlgebra
using Groebner
using Nemo

# Performance tools
using BenchmarkTools

# Include core modules
include("core/constants.jl")
include("core/types.jl")
include("core/utilities.jl")

# Mathematical libraries
include("math/numerical_methods.jl")
include("math/special_functions.jl")
include("math/linear_algebra.jl")
include("math/differential_equations.jl")

# Physics modules
include("physics/yukawa_potential.jl")
include("physics/quantum_mechanics.jl")
include("physics/classical_mechanics.jl")
include("physics/electromagnetism.jl")

# Visualization modules
include("visualization/plotting.jl")
include("visualization/animations.jl")
include("visualization/interactive.jl")

# Export main functionality
export 
    # Yukawa potential functions
    yukawa_potential,
    yukawa_force,
    solve_yukawa_schrodinger,
    yukawa_scattering,
    yukawa_bound_states,
    
    # Mathematical utilities
    adaptive_integration,
    finite_difference,
    spectral_methods,
    eigenvalue_solver,
    
    # Quantum mechanics
    wavefunction,
    probability_density,
    expectation_value,
    uncertainty,
    time_evolution,
    
    # Classical mechanics
    lagrangian,
    hamiltonian,
    equations_of_motion,
    phase_space,
    
    # Electromagnetic theory
    electric_field,
    magnetic_field,
    electromagnetic_waves,
    
    # Visualization
    plot_potential,
    plot_wavefunction,
    animate_evolution,
    interactive_plot,
    
    # Constants and types
    PhysicsConstants,
    YukawaPotential,
    QuantumState,
    ClassicalSystem

# Package information
const VERSION = v"1.0.0"
const AUTHORS = ["Physicist"]
const DESCRIPTION = "Revolutionary computational physics package for Yukawa potential analysis"

"""
    welcome()

Display welcome message and package information.
"""
function welcome()
    println("🚀 Welcome to YukawaPhysics.jl v$VERSION")
    println("   Revolutionary Computational Physics Package")
    println("   Focus: Yukawa Potential & Advanced Mathematical Methods")
    println()
    println("📚 Key Features:")
    println("   • Advanced Yukawa potential solvers")
    println("   • Quantum mechanical calculations")
    println("   • Interactive visualizations")
    println("   • Publication-ready mathematics")
    println("   • Web deployment capabilities")
    println()
    println("🔬 Start exploring with: YukawaPhysics.examples()")
    println("📖 Documentation: YukawaPhysics.docs()")
end

"""
    examples()

Show available examples and tutorials.
"""
function examples()
    println("📊 Available Examples:")
    println("   1. Basic Yukawa potential: yukawa_basic_example()")
    println("   2. Quantum scattering: quantum_scattering_example()")
    println("   3. Bound state analysis: bound_states_example()")
    println("   4. Interactive visualization: interactive_example()")
    println("   5. Performance benchmarks: benchmark_example()")
    println()
    println("🎓 Tutorials available in notebooks/ directory")
end

"""
    docs()

Display documentation information.
"""
function docs()
    println("📚 Documentation Structure:")
    println("   • API Reference: docs/api/")
    println("   • Mathematical Theory: latex/theory/")
    println("   • Interactive Notebooks: notebooks/")
    println("   • Examples: examples/")
    println("   • Development Guide: docs/development/")
    println()
    println("🌐 Web Documentation: Available after running deploy_docs()")
end

# Module initialization
function __init__()
    # Set default plotting backend
    plotlyjs()
    
    # Configure physics-friendly plot defaults
    default(
        fontfamily="Computer Modern",
        linewidth=2,
        markersize=6,
        grid=true,
        gridwidth=1,
        gridcolor=:gray,
        gridalpha=0.3,
        legend=:topright,
        dpi=300
    )
    
    # Display welcome message
    welcome()
end

end # module YukawaPhysics