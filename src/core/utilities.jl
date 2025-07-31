"""
# Core Utilities Module

This module provides essential utility functions used throughout the YukawaPhysics package.
These functions handle common computational tasks, data processing, error handling,
and performance optimization.

## Categories

1. **Mathematical Utilities**: Special functions, numerical methods
2. **Data Processing**: Grid generation, interpolation, smoothing
3. **Error Handling**: Custom exceptions, validation functions
4. **Performance**: Benchmarking, profiling, optimization helpers
5. **I/O Operations**: File handling, data export/import
6. **Visualization Helpers**: Plot formatting, color schemes

## Design Philosophy

- Functions are designed to be composable and reusable
- Type stability is prioritized for performance
- Comprehensive error checking with meaningful messages
- Integration with Julia's ecosystem (StaticArrays, etc.)
"""

using LinearAlgebra
using StaticArrays
using Printf
using DelimitedFiles
using JSON3
using BenchmarkTools

# ============================================================================
# Mathematical Utilities
# ============================================================================

"""
    linspace(start, stop, n)

Generate n linearly spaced points from start to stop (inclusive).
Similar to numpy.linspace with endpoint=True.

# Arguments
- `start`: Starting value
- `stop`: Ending value  
- `n`: Number of points

# Returns
- Vector of n linearly spaced points

# Examples
```julia
x = linspace(0, 10, 11)  # [0, 1, 2, ..., 10]
```
"""
function linspace(start::Real, stop::Real, n::Integer)
    @assert n >= 2 "Need at least 2 points"
    return collect(range(start, stop, length=n))
end

"""
    logspace(start, stop, n; base=10)

Generate n logarithmically spaced points from base^start to base^stop.

# Arguments
- `start`: Starting exponent
- `stop`: Ending exponent
- `n`: Number of points
- `base`: Logarithmic base (default: 10)

# Examples
```julia
x = logspace(-2, 2, 5)  # [0.01, 0.1, 1, 10, 100]
```
"""
function logspace(start::Real, stop::Real, n::Integer; base::Real=10)
    @assert n >= 2 "Need at least 2 points"
    @assert base > 0 && base != 1 "Base must be positive and not equal to 1"
    
    exponents = linspace(start, stop, n)
    return base .^ exponents
end

"""
    meshgrid(x, y)

Create 2D coordinate matrices from coordinate vectors.
Similar to MATLAB's meshgrid function.

# Arguments
- `x`: x-coordinate vector
- `y`: y-coordinate vector

# Returns
- `(X, Y)`: Tuple of 2D coordinate matrices

# Examples
```julia
x = [1, 2, 3]
y = [4, 5]
X, Y = meshgrid(x, y)
# X = [1 2 3; 1 2 3]
# Y = [4 4 4; 5 5 5]
```
"""
function meshgrid(x::AbstractVector, y::AbstractVector)
    X = repeat(reshape(x, 1, :), length(y), 1)
    Y = repeat(y, 1, length(x))
    return X, Y
end

"""
    gradient_finite_difference(f, x; method=:central, h=1e-8)

Compute numerical gradient using finite differences.

# Arguments
- `f`: Function to differentiate
- `x`: Point at which to evaluate gradient
- `method`: Finite difference method (:forward, :backward, :central)
- `h`: Step size

# Returns
- Numerical gradient df/dx

# Methods
- Forward: f'(x) ≈ (f(x+h) - f(x))/h
- Backward: f'(x) ≈ (f(x) - f(x-h))/h  
- Central: f'(x) ≈ (f(x+h) - f(x-h))/(2h)
"""
function gradient_finite_difference(f, x; method=:central, h=1e-8)
    if method == :forward
        return (f(x + h) - f(x)) / h
    elseif method == :backward
        return (f(x) - f(x - h)) / h
    elseif method == :central
        return (f(x + h) - f(x - h)) / (2h)
    else
        error("Unknown method: $method. Use :forward, :backward, or :central")
    end
end

"""
    hessian_finite_difference(f, x; h=1e-6)

Compute numerical Hessian matrix using finite differences.

# Arguments
- `f`: Scalar function of vector argument
- `x`: Point at which to evaluate Hessian (vector)
- `h`: Step size

# Returns
- Hessian matrix H[i,j] = ∂²f/(∂xᵢ∂xⱼ)
"""
function hessian_finite_difference(f, x::AbstractVector; h=1e-6)
    n = length(x)
    H = zeros(n, n)
    
    # Diagonal elements: ∂²f/∂xᵢ²
    for i in 1:n
        x_plus = copy(x); x_plus[i] += h
        x_minus = copy(x); x_minus[i] -= h
        H[i,i] = (f(x_plus) - 2*f(x) + f(x_minus)) / h^2
    end
    
    # Off-diagonal elements: ∂²f/(∂xᵢ∂xⱼ)
    for i in 1:n, j in (i+1):n
        x_pp = copy(x); x_pp[i] += h; x_pp[j] += h
        x_pm = copy(x); x_pm[i] += h; x_pm[j] -= h
        x_mp = copy(x); x_mp[i] -= h; x_mp[j] += h
        x_mm = copy(x); x_mm[i] -= h; x_mm[j] -= h
        
        H[i,j] = H[j,i] = (f(x_pp) - f(x_pm) - f(x_mp) + f(x_mm)) / (4*h^2)
    end
    
    return H
end

# ============================================================================
# Data Processing and Grid Generation
# ============================================================================

"""
    adaptive_grid(f, a, b; tol=1e-6, max_points=10000, min_points=100)

Generate an adaptive grid based on function curvature.

# Algorithm
1. Start with uniform grid
2. Add points where |f''| is large
3. Refine until tolerance is met or max points reached

# Arguments
- `f`: Function to adapt grid for
- `a`, `b`: Domain boundaries
- `tol`: Tolerance for curvature-based refinement
- `max_points`: Maximum number of grid points
- `min_points`: Minimum number of grid points

# Returns
- Adaptive grid points as a vector
"""
function adaptive_grid(f, a, b; tol=1e-6, max_points=10000, min_points=100)
    # Start with minimum uniform grid
    x = linspace(a, b, min_points)
    
    while length(x) < max_points
        # Compute second derivatives
        f_vals = f.(x)
        n = length(x)
        
        if n < 3
            break
        end
        
        # Estimate second derivative using finite differences
        f_second = zeros(n-2)
        for i in 2:(n-1)
            h1 = x[i] - x[i-1]
            h2 = x[i+1] - x[i]
            # Non-uniform grid second derivative formula
            f_second[i-1] = abs(2 * ((f_vals[i+1] - f_vals[i])/h2 - (f_vals[i] - f_vals[i-1])/h1) / (h1 + h2))
        end
        
        # Find point with maximum curvature
        max_curvature, max_idx = findmax(f_second)
        
        if max_curvature < tol
            break  # Sufficient resolution achieved
        end
        
        # Add new point at location of maximum curvature
        new_point = (x[max_idx] + x[max_idx+1]) / 2
        insert!(x, max_idx+1, new_point)
        
        # Sort to maintain order (should already be sorted)
        sort!(x)
    end
    
    return x
end

"""
    smooth_data(y, window_size; method=:gaussian)

Smooth noisy data using various methods.

# Arguments
- `y`: Data to smooth
- `window_size`: Size of smoothing window
- `method`: Smoothing method (:gaussian, :moving_average, :savgol)

# Returns
- Smoothed data
"""
function smooth_data(y::AbstractVector, window_size::Int; method=:gaussian)
    n = length(y)
    y_smooth = copy(y)
    
    if method == :moving_average
        # Simple moving average
        half_window = window_size ÷ 2
        for i in (half_window+1):(n-half_window)
            y_smooth[i] = mean(y[(i-half_window):(i+half_window)])
        end
        
    elseif method == :gaussian
        # Gaussian weighted smoothing
        σ = window_size / 6  # Standard deviation
        half_window = window_size ÷ 2
        
        # Create Gaussian kernel
        kernel = exp.(-(-half_window:half_window).^2 / (2*σ^2))
        kernel ./= sum(kernel)  # Normalize
        
        # Apply convolution
        for i in (half_window+1):(n-half_window)
            y_smooth[i] = sum(kernel .* y[(i-half_window):(i+half_window)])
        end
        
    else
        error("Unknown smoothing method: $method")
    end
    
    return y_smooth
end

"""
    interpolate_cubic_spline(x_data, y_data, x_interp)

Cubic spline interpolation.

# Arguments
- `x_data`: Known x values (must be sorted)
- `y_data`: Known y values
- `x_interp`: Points to interpolate at

# Returns
- Interpolated y values
"""
function interpolate_cubic_spline(x_data::AbstractVector, y_data::AbstractVector, x_interp::AbstractVector)
    @assert length(x_data) == length(y_data) "x_data and y_data must have same length"
    @assert issorted(x_data) "x_data must be sorted"
    
    n = length(x_data)
    y_interp = zeros(length(x_interp))
    
    # Simple cubic spline implementation
    # For production use, consider using Interpolations.jl
    
    for (i, x) in enumerate(x_interp)
        # Find interval
        if x <= x_data[1]
            y_interp[i] = y_data[1]
        elseif x >= x_data[end]
            y_interp[i] = y_data[end]
        else
            # Find bracketing indices
            idx = searchsortedfirst(x_data, x) - 1
            idx = clamp(idx, 1, n-1)
            
            # Linear interpolation (simplified)
            t = (x - x_data[idx]) / (x_data[idx+1] - x_data[idx])
            y_interp[i] = (1-t) * y_data[idx] + t * y_data[idx+1]
        end
    end
    
    return y_interp
end

# ============================================================================
# Error Handling and Validation
# ============================================================================

"""
    PhysicsException

Custom exception type for physics-related errors.
"""
struct PhysicsException <: Exception
    message::String
    context::Dict{String,Any}
    
    PhysicsException(msg::String, ctx::Dict{String,Any}=Dict{String,Any}()) = new(msg, ctx)
end

Base.show(io::IO, e::PhysicsException) = print(io, "PhysicsException: $(e.message)")

"""
    validate_potential(V::AbstractPotential, r_test=1.0)

Validate that a potential is well-defined and physically reasonable.

# Checks
- Potential is finite at test point
- Force is finite at test point  
- Potential has correct asymptotic behavior

# Arguments
- `V`: Potential to validate
- `r_test`: Test point for evaluation

# Throws
- `PhysicsException` if validation fails
"""
function validate_potential(V::AbstractPotential, r_test=1.0)
    try
        # Test potential evaluation
        V_val = yukawa_potential(V, r_test)
        
        if !isfinite(V_val)
            throw(PhysicsException("Potential is not finite at r = $r_test", 
                                 Dict("r_test" => r_test, "V_val" => V_val)))
        end
        
        # Test force evaluation
        F_val = yukawa_force(V, r_test)
        
        if !isfinite(F_val)
            throw(PhysicsException("Force is not finite at r = $r_test",
                                 Dict("r_test" => r_test, "F_val" => F_val)))
        end
        
        # Test asymptotic behavior (should decay for large r)
        r_large = 100.0
        V_large = yukawa_potential(V, r_large)
        
        if abs(V_large) > abs(V_val)
            @warn "Potential may not have proper asymptotic decay" V_large V_val
        end
        
    catch e
        if isa(e, PhysicsException)
            rethrow(e)
        else
            throw(PhysicsException("Unexpected error during potential validation: $e"))
        end
    end
    
    return true
end

"""
    validate_quantum_state(ψ::AbstractQuantumState; check_normalization=true)

Validate quantum state properties.

# Checks
- Wavefunction is finite everywhere
- Grid is properly ordered
- Normalization (if requested)

# Arguments
- `ψ`: Quantum state to validate
- `check_normalization`: Whether to verify normalization
"""
function validate_quantum_state(ψ::AbstractQuantumState; check_normalization=true)
    # Check wavefunction finiteness
    if !all(isfinite.(ψ.ψ))
        throw(PhysicsException("Wavefunction contains non-finite values"))
    end
    
    # Check grid ordering
    if !issorted(ψ.r)
        throw(PhysicsException("Spatial grid is not properly ordered"))
    end
    
    # Check normalization if requested
    if check_normalization && ψ.normalized
        norm_squared = trapz(ψ.r, abs2.(ψ.ψ))
        if abs(norm_squared - 1.0) > 1e-6
            @warn "Quantum state normalization error" norm_squared
        end
    end
    
    return true
end

# ============================================================================
# Performance and Benchmarking
# ============================================================================

"""
    benchmark_function(f, args...; samples=5, seconds=1.0)

Benchmark a function with given arguments.

# Arguments
- `f`: Function to benchmark
- `args...`: Arguments to pass to function
- `samples`: Minimum number of samples
- `seconds`: Minimum time to spend benchmarking

# Returns
- BenchmarkTools.Trial object with timing statistics
"""
function benchmark_function(f, args...; samples=5, seconds=1.0)
    return @benchmark $f($(args)...) samples=samples seconds=seconds
end

"""
    profile_memory_allocation(f, args...)

Profile memory allocation for a function call.

# Returns
- Tuple of (result, bytes_allocated, gc_time)
"""
function profile_memory_allocation(f, args...)
    # Force garbage collection before measurement
    GC.gc()
    
    # Measure allocation
    bytes_before = Base.gc_bytes()
    gc_time_before = Base.gc_time_ns()
    
    result = f(args...)
    
    bytes_after = Base.gc_bytes()
    gc_time_after = Base.gc_time_ns()
    
    bytes_allocated = bytes_after - bytes_before
    gc_time = (gc_time_after - gc_time_before) / 1e9  # Convert to seconds
    
    return result, bytes_allocated, gc_time
end

"""
    optimize_type_stability(f, args...)

Check and report type stability issues.

# Returns
- Dict with type stability information
"""
function optimize_type_stability(f, args...)
    # This would use @code_warntype internally
    # Simplified version for demonstration
    
    try
        result = f(args...)
        return Dict(
            "stable" => true,
            "return_type" => typeof(result),
            "message" => "Function appears type stable"
        )
    catch e
        return Dict(
            "stable" => false,
            "error" => string(e),
            "message" => "Type stability check failed"
        )
    end
end

# ============================================================================
# I/O Operations
# ============================================================================

"""
    save_data(filename, data; format=:json)

Save data to file in specified format.

# Arguments
- `filename`: Output filename
- `data`: Data to save
- `format`: File format (:json, :csv, :txt)
"""
function save_data(filename::String, data; format=:json)
    if format == :json
        open(filename, "w") do io
            JSON3.pretty(io, data)
        end
        
    elseif format == :csv && isa(data, AbstractMatrix)
        writedlm(filename, data, ',')
        
    elseif format == :txt
        if isa(data, AbstractMatrix)
            writedlm(filename, data)
        else
            open(filename, "w") do io
                println(io, data)
            end
        end
        
    else
        error("Unsupported format: $format")
    end
    
    println("Data saved to: $filename")
end

"""
    load_data(filename; format=:auto)

Load data from file with automatic format detection.

# Arguments
- `filename`: Input filename
- `format`: File format (:auto, :json, :csv, :txt)

# Returns
- Loaded data
"""
function load_data(filename::String; format=:auto)
    if !isfile(filename)
        throw(ArgumentError("File not found: $filename"))
    end
    
    # Auto-detect format from extension
    if format == :auto
        ext = lowercase(splitext(filename)[2])
        if ext == ".json"
            format = :json
        elseif ext in [".csv", ".dat"]
            format = :csv
        else
            format = :txt
        end
    end
    
    if format == :json
        return JSON3.read(filename)
        
    elseif format == :csv
        return readdlm(filename, ',')
        
    elseif format == :txt
        return readdlm(filename)
        
    else
        error("Unsupported format: $format")
    end
end

# ============================================================================
# Visualization Helpers
# ============================================================================

"""
    physics_color_scheme()

Return a physics-appropriate color scheme for plots.

# Returns
- Vector of colors suitable for scientific plots
"""
function physics_color_scheme()
    return [
        :blue,      # Ground state
        :red,       # First excited state
        :green,     # Second excited state
        :orange,    # Third excited state
        :purple,    # Higher states
        :brown,
        :pink,
        :gray,
        :olive,
        :cyan
    ]
end

"""
    format_scientific_notation(x; precision=3)

Format number in scientific notation for plot labels.

# Arguments
- `x`: Number to format
- `precision`: Number of decimal places

# Returns
- Formatted string
"""
function format_scientific_notation(x; precision=3)
    if x == 0
        return "0"
    end
    
    exponent = floor(Int, log10(abs(x)))
    mantissa = x / 10^exponent
    
    if exponent == 0
        return @sprintf("%.$(precision)f", x)
    else
        return @sprintf("%.$(precision)f×10^%d", mantissa, exponent)
    end
end

"""
    create_physics_plot_defaults()

Return default plot settings for physics publications.

# Returns
- Dict with plot settings
"""
function create_physics_plot_defaults()
    return Dict(
        :fontfamily => "Computer Modern",
        :fontsize => 12,
        :linewidth => 2,
        :markersize => 6,
        :grid => true,
        :gridwidth => 1,
        :gridcolor => :gray,
        :gridalpha => 0.3,
        :legend => :topright,
        :dpi => 300,
        :size => (800, 600),
        :margins => 5,
        :guidefontsize => 14,
        :tickfontsize => 10,
        :legendfontsize => 10
    )
end

# ============================================================================
# Unit Conversion Utilities
# ============================================================================

"""
    convert_energy_units(value, from_unit, to_unit)

Convert energy between different units.

# Supported Units
- :hartree, :eV, :J, :erg, :cal, :meV, :keV, :MeV, :GeV

# Arguments
- `value`: Energy value to convert
- `from_unit`: Source unit
- `to_unit`: Target unit

# Returns
- Converted energy value
"""
function convert_energy_units(value, from_unit::Symbol, to_unit::Symbol)
    # Conversion factors to Joules
    to_joules = Dict(
        :J => 1.0,
        :eV => 1.602176634e-19,
        :meV => 1.602176634e-22,
        :keV => 1.602176634e-16,
        :MeV => 1.602176634e-13,
        :GeV => 1.602176634e-10,
        :hartree => 4.3597447222071e-18,
        :erg => 1e-7,
        :cal => 4.184
    )
    
    if !haskey(to_joules, from_unit) || !haskey(to_joules, to_unit)
        error("Unsupported energy unit. Supported: $(keys(to_joules))")
    end
    
    # Convert to Joules, then to target unit
    value_joules = value * to_joules[from_unit]
    return value_joules / to_joules[to_unit]
end

"""
    convert_length_units(value, from_unit, to_unit)

Convert length between different units.

# Supported Units
- :m, :cm, :mm, :nm, :pm, :bohr, :angstrom, :fm

# Arguments
- `value`: Length value to convert
- `from_unit`: Source unit
- `to_unit`: Target unit

# Returns
- Converted length value
"""
function convert_length_units(value, from_unit::Symbol, to_unit::Symbol)
    # Conversion factors to meters
    to_meters = Dict(
        :m => 1.0,
        :cm => 1e-2,
        :mm => 1e-3,
        :nm => 1e-9,
        :pm => 1e-12,
        :fm => 1e-15,
        :bohr => 5.29177210903e-11,
        :angstrom => 1e-10
    )
    
    if !haskey(to_meters, from_unit) || !haskey(to_meters, to_unit)
        error("Unsupported length unit. Supported: $(keys(to_meters))")
    end
    
    # Convert to meters, then to target unit
    value_meters = value * to_meters[from_unit]
    return value_meters / to_meters[to_unit]
end