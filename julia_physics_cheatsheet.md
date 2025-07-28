# Julia for Physicists: Quick Reference Cheatsheet

## Basic Syntax

### Variables and Constants
```julia
# Variables (mutable)
x = 1.0
mass = 9.109e-31  # electron mass in kg

# Constants (immutable)
const c = 2.998e8  # speed of light

# Unicode symbols (great for physics!)
α = 7.297e-3      # fine structure constant
λ = 550e-9        # wavelength
ħ = 1.055e-34     # reduced Planck constant
θ = π/4           # angle
ω = 2π            # angular frequency
```

### Arrays and Vectors
```julia
# 1D arrays (vectors)
position = [1.0, 2.0, 3.0]
velocity = [0.5, -1.2, 0.8]

# 2D arrays (matrices)
rotation = [cos(θ) -sin(θ); sin(θ) cos(θ)]

# Array operations
magnitude = sqrt(sum(velocity.^2))  # or norm(velocity)
dot_product = sum(position .* velocity)  # or dot(position, velocity)

# Element-wise operations (use . before operator)
kinetic_energy = 0.5 * mass .* velocity.^2
```

### Functions
```julia
# Single-line function
kinetic_energy(m, v) = 0.5 * m * v^2

# Multi-line function
function gravitational_force(m1, m2, r)
    G = 6.674e-11
    return G * m1 * m2 / r^2
end

# Anonymous function
f = x -> x^2 + 2x + 1

# Multiple return values
function orbital_params(r, v, M)
    E_kinetic = 0.5 * v^2
    E_potential = -G * M / r
    E_total = E_kinetic + E_potential
    return E_kinetic, E_potential, E_total
end
```

## Mathematical Operations

### Basic Math
```julia
# Arithmetic
2 + 3, 5 - 2, 3 * 4, 8 / 2, 2^3

# Mathematical functions
sin(π/2), cos(0), tan(π/4)
exp(1), log(e), log10(100)
sqrt(4), cbrt(8), abs(-5)

# Complex numbers
z = 3 + 4im
abs(z)      # magnitude
angle(z)    # phase
real(z)     # real part
imag(z)     # imaginary part
```

### Linear Algebra
```julia
using LinearAlgebra

# Vector operations
dot(a, b)           # dot product
cross(a, b)         # cross product (3D only)
norm(v)             # magnitude
normalize(v)        # unit vector

# Matrix operations
A * B               # matrix multiplication
A'                  # transpose
inv(A)              # inverse
det(A)              # determinant
eigen(A)            # eigenvalues and eigenvectors
```

### Ranges and Arrays
```julia
# Ranges
t = 0:0.1:10        # from 0 to 10, step 0.1
x = range(0, 10, length=100)  # 100 points from 0 to 10

# Array creation
zeros(5)            # [0, 0, 0, 0, 0]
ones(3, 3)          # 3×3 matrix of ones
rand(4)             # random numbers [0,1)
randn(4)            # random normal distribution

# Array indexing (1-based!)
arr[1]              # first element
arr[end]            # last element
arr[2:4]            # elements 2 through 4
arr[1:2:end]        # every second element
```

## Physics-Specific Patterns

### Physical Constants
```julia
using PhysicalConstants.CODATA2018

# Common constants
c_0.val             # speed of light
ħ.val               # reduced Planck constant
e.val               # elementary charge
m_e.val             # electron mass
k_B.val             # Boltzmann constant
```

### Units
```julia
using Unitful

# Define quantities with units
distance = 5.0u"m"
time = 2.0u"s"
velocity = distance / time  # automatically 2.5 m/s

# Unit conversions
energy = 1.0u"eV"
energy_joules = uconvert(u"J", energy)
```

### Differential Equations
```julia
using DifferentialEquations

# Define ODE system
function oscillator!(du, u, p, t)
    x, v = u
    ω = p[1]
    du[1] = v           # dx/dt = v
    du[2] = -ω^2 * x    # dv/dt = -ω²x
end

# Solve
u0 = [1.0, 0.0]        # initial conditions
tspan = (0.0, 10.0)    # time span
p = [2π]               # parameters
prob = ODEProblem(oscillator!, u0, tspan, p)
sol = solve(prob)
```

### Plotting
```julia
using Plots

# Basic plot
plot(x, y, xlabel="x", ylabel="y", title="My Plot")

# Multiple series
plot(t, [sin.(t) cos.(t)], label=["sin" "cos"])

# 3D plot
plot(x, y, z, xlabel="x", ylabel="y", zlabel="z")

# Save plot
savefig("myplot.png")
```

## Control Flow

### Conditionals
```julia
if x > 0
    println("positive")
elseif x < 0
    println("negative")
else
    println("zero")
end

# Ternary operator
result = x > 0 ? "positive" : "non-positive"
```

### Loops
```julia
# For loops
for i in 1:10
    println(i)
end

for (i, value) in enumerate(array)
    println("Index $i: $value")
end

# While loops
while condition
    # do something
end
```

### Comprehensions
```julia
# Array comprehension
squares = [x^2 for x in 1:10]
even_squares = [x^2 for x in 1:10 if x % 2 == 0]

# Generator (memory efficient)
sum(x^2 for x in 1:1000000)
```

## Performance Tips

### Type Stability
```julia
# Good: type-stable function
function good_function(x::Float64)
    if x > 0
        return x^2      # always returns Float64
    else
        return 0.0      # same type
    end
end

# Bad: type-unstable function
function bad_function(x::Float64)
    if x > 0
        return x^2      # Float64
    else
        return "zero"   # String - different type!
    end
end
```

### Broadcasting
```julia
# Use . for element-wise operations
result = sin.(x_array)  # applies sin to each element
y = a .* x .+ b         # element-wise: y[i] = a * x[i] + b

# Fuse operations for better performance
@. y = a * x + b        # equivalent to above, but faster
```

### Memory Allocation
```julia
# Pre-allocate arrays when possible
result = zeros(length(x))
for i in eachindex(x)
    result[i] = expensive_function(x[i])
end

# Use views instead of copies
view(matrix, 1:10, :)   # creates a view, not a copy
```

## Debugging and Profiling

### Debugging
```julia
# Print debugging
@show variable_name     # prints "variable_name = value"
println("Debug: x = $x")

# Check types
typeof(x)
eltype(array)           # element type of array
```

### Performance
```julia
using BenchmarkTools

# Benchmark code
@time expensive_function()      # time and memory
@btime expensive_function()     # more accurate timing
@benchmark expensive_function() # detailed statistics

# Profile code
using Profile
@profile expensive_function()
Profile.print()
```

## Package Management

### In Julia REPL
```julia
# Enter package mode with ]
] add Plots DifferentialEquations
] remove PackageName
] update
] status        # show installed packages
] activate .    # activate local environment
```

### In Scripts
```julia
using Pkg
Pkg.add("PackageName")
Pkg.update()
```

## Common Physics Packages

```julia
# Essential packages
using Plots                    # Plotting
using DifferentialEquations   # ODEs, PDEs
using LinearAlgebra           # Linear algebra
using Statistics              # Statistical functions
using Unitful                 # Physical units
using PhysicalConstants       # Physical constants

# Specialized physics
using QuantumOptics           # Quantum mechanics
using FFTW                    # Fast Fourier transforms
using DSP                     # Signal processing
using Optimization           # Optimization algorithms
using ForwardDiff            # Automatic differentiation
```

## Quick Examples

### Simple Harmonic Oscillator
```julia
ω = 2π
t = 0:0.01:2
x = cos.(ω .* t)
plot(t, x, xlabel="Time", ylabel="Position")
```

### Projectile Motion
```julia
g = 9.81
v0, θ = 20.0, π/4
t = 0:0.01:2*v0*sin(θ)/g
x = v0 * cos(θ) .* t
y = v0 * sin(θ) .* t .- 0.5 * g .* t.^2
plot(x, y, xlabel="Range", ylabel="Height")
```

### Maxwell-Boltzmann Distribution
```julia
k_B, T, m = 1.381e-23, 300, 4.65e-26
v = 0:10:1500
f = @. 4π * v^2 * (m/(2π*k_B*T))^(3/2) * exp(-m*v^2/(2*k_B*T))
plot(v, f, xlabel="Speed (m/s)", ylabel="Probability Density")
```

---

**Remember**: Julia uses 1-based indexing (unlike Python/C), and the `.` operator is crucial for element-wise operations!