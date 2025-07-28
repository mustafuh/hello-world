#!/bin/bash

# Julia Setup Script for Physicists
# This script helps install Julia and essential packages for physics computing

echo "=== Julia Setup for Physicists ==="
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Julia is already installed
if command_exists julia; then
    echo "✓ Julia is already installed!"
    julia --version
    echo ""
else
    echo "Installing Julia..."
    
    # Try different installation methods
    if command_exists curl; then
        echo "Using juliaup installer..."
        curl -fsSL https://install.julialang.org | sh -s -- --yes
        
        # Add to PATH for current session
        export PATH="$HOME/.juliaup/bin:$PATH"
        
        echo "Julia installation completed!"
        echo "Please restart your terminal or run: source ~/.bashrc"
        echo ""
    else
        echo "❌ curl not found. Please install curl first or download Julia manually from:"
        echo "https://julialang.org/downloads/"
        exit 1
    fi
fi

# Check if Julia is now available
if command_exists julia; then
    echo "Installing essential packages for physics..."
    
    # Create a Julia script to install packages
    cat > install_packages.jl << 'EOF'
using Pkg

println("Installing essential packages for physics...")

# Core packages
essential_packages = [
    "Plots",                # Plotting and visualization
    "DifferentialEquations", # Solve ODEs, PDEs, etc.
    "LinearAlgebra",        # Linear algebra (built-in, but good to have)
    "Statistics",           # Statistical functions (built-in)
    "Random",              # Random number generation (built-in)
    "BenchmarkTools",      # Performance benchmarking
    "Unitful",             # Physical units
    "PhysicalConstants",   # Physical constants
    "StaticArrays",        # Fast small arrays
    "ForwardDiff",         # Automatic differentiation
    "Optimization",        # Optimization algorithms
    "DataFrames",          # Data manipulation
    "CSV",                 # CSV file handling
    "JSON3",               # JSON handling
    "Printf"               # Formatted printing (built-in)
]

println("Installing packages...")
for pkg in essential_packages
    try
        println("Installing $pkg...")
        Pkg.add(pkg)
        println("✓ $pkg installed successfully")
    catch e
        println("❌ Failed to install $pkg: $e")
    end
end

# Physics-specific packages (optional, might not all be available)
physics_packages = [
    "QuantumOptics",       # Quantum mechanics simulations
    "Unitful",             # Physical units (already included above)
    "UnitfulAstro",        # Astronomical units
    "AstroLib",            # Astronomy utilities
    "FFTW",                # Fast Fourier transforms
    "DSP",                 # Digital signal processing
    "Images",              # Image processing
    "WAV",                 # Audio file handling
    "PyPlot"               # Alternative plotting (requires Python/matplotlib)
]

println("\nInstalling physics-specific packages (some may fail if dependencies are missing)...")
for pkg in physics_packages
    try
        println("Installing $pkg...")
        Pkg.add(pkg)
        println("✓ $pkg installed successfully")
    catch e
        println("⚠ Failed to install $pkg (this is often okay): $e")
    end
end

println("\n=== Package Installation Complete ===")
println("Installed packages are ready for use!")

# Test basic functionality
println("\nTesting basic functionality...")
try
    using Plots
    println("✓ Plots.jl working")
catch e
    println("❌ Plots.jl test failed: $e")
end

try
    using DifferentialEquations
    println("✓ DifferentialEquations.jl working")
catch e
    println("❌ DifferentialEquations.jl test failed: $e")
end

try
    using LinearAlgebra
    println("✓ LinearAlgebra working")
catch e
    println("❌ LinearAlgebra test failed: $e")
end

println("\nSetup complete! You can now run the example files:")
println("- julia examples/01_basic_physics.jl")
println("- julia examples/02_plotting_examples.jl")
println("- julia examples/03_differential_equations.jl")
EOF

    # Run the package installation
    echo "Running Julia package installation..."
    julia install_packages.jl
    
    # Clean up
    rm install_packages.jl
    
    echo ""
    echo "=== Setup Complete! ==="
    echo ""
    echo "Next steps:"
    echo "1. Try running: julia examples/01_basic_physics.jl"
    echo "2. Explore the examples in the examples/ directory"
    echo "3. Read the comprehensive guide in README.md"
    echo ""
    echo "Useful Julia commands:"
    echo "- julia                    # Start Julia REPL"
    echo "- julia script.jl          # Run a Julia script"
    echo "- julia -e 'println(2+2)'  # Run Julia expression"
    echo ""
    echo "In Julia REPL:"
    echo "- ]                        # Enter package mode"
    echo "- ?                        # Enter help mode"
    echo "- ;                        # Enter shell mode"
    echo "- Ctrl+D                   # Exit Julia"
    echo ""
    echo "Happy coding with Julia! 🚀"
    
else
    echo "❌ Julia installation failed. Please try manual installation:"
    echo "1. Visit https://julialang.org/downloads/"
    echo "2. Download the appropriate version for your system"
    echo "3. Follow the installation instructions"
    echo "4. Run this script again"
fi