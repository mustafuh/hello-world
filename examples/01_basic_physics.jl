# Basic Physics Examples in Julia
# Run this file with: julia 01_basic_physics.jl

println("=== Julia for Physicists: Basic Examples ===\n")

# 1. Physical Constants and Unicode Support
println("1. Physical Constants and Unicode Support")
println("==========================================")

# Julia has excellent Unicode support - great for physics notation!
c = 2.998e8      # speed of light (m/s)
ħ = 1.055e-34    # reduced Planck constant (J⋅s)
e = 1.602e-19    # elementary charge (C)
k_B = 1.381e-23  # Boltzmann constant (J/K)
α = 7.297e-3     # fine structure constant
λ = 550e-9       # wavelength (m)

println("Speed of light: c = $c m/s")
println("Reduced Planck constant: ℏ = $ħ J⋅s")
println("Elementary charge: e = $e C")
println("Fine structure constant: α = $α")
println("Wavelength: λ = $λ m")
println()

# 2. Vectors and Basic Operations
println("2. Vector Operations (3D Physics)")
println("==================================")

# Position and velocity vectors
r⃗ = [1.0, 2.0, 3.0]  # position vector (m)
v⃗ = [0.5, -1.2, 0.8] # velocity vector (m/s)

println("Position vector: r⃗ = $r⃗")
println("Velocity vector: v⃗ = $v⃗")

# Vector operations
speed = sqrt(sum(v⃗.^2))  # or use norm(v⃗) with LinearAlgebra
println("Speed: |v⃗| = $speed m/s")

# Dot product (scalar)
dot_product = sum(r⃗ .* v⃗)  # or use dot(r⃗, v⃗)
println("r⃗ · v⃗ = $dot_product")

# Cross product (for 3D vectors)
function cross_product(a, b)
    return [a[2]*b[3] - a[3]*b[2],
            a[3]*b[1] - a[1]*b[3],
            a[1]*b[2] - a[2]*b[1]]
end

cross = cross_product(r⃗, v⃗)
println("r⃗ × v⃗ = $cross")
println()

# 3. Functions for Physics Calculations
println("3. Physics Functions")
println("====================")

# Gravitational force
function gravitational_force(m1, m2, r)
    G = 6.674e-11  # gravitational constant (N⋅m²/kg²)
    return G * m1 * m2 / r^2
end

# Example: Force between Earth and Moon
M_earth = 5.972e24  # kg
M_moon = 7.342e22   # kg
r_earth_moon = 3.844e8  # m

F_gravity = gravitational_force(M_earth, M_moon, r_earth_moon)
println("Gravitational force between Earth and Moon: $(F_gravity) N")

# Kinetic energy
kinetic_energy(m, v) = 0.5 * m * v^2

# Example
m = 1000.0  # kg
v = 30.0    # m/s
KE = kinetic_energy(m, v)
println("Kinetic energy of 1000 kg object at 30 m/s: $(KE) J")
println()

# 4. Arrays and Element-wise Operations
println("4. Arrays and Element-wise Operations")
println("=====================================")

# Time array
t = 0:0.1:5.0  # from 0 to 5 seconds, step 0.1
println("Time array (first 10 points): $(collect(t)[1:10])")

# Position of falling object
g = 9.81  # acceleration due to gravity
h₀ = 100.0  # initial height
y = h₀ .- 0.5 * g .* t.^2  # element-wise operations with .

# Find when object hits ground
ground_index = findfirst(y .<= 0)
if ground_index !== nothing
    t_impact = t[ground_index]
    println("Object hits ground at t = $(t_impact) s")
end
println()

# 5. Complex Numbers (useful in quantum mechanics and AC circuits)
println("5. Complex Numbers")
println("==================")

# Complex impedance in AC circuit
Z₁ = 100 + 50im  # 100 Ω resistance + 50 Ω reactance
Z₂ = 75 - 25im   # another impedance

Z_total = Z₁ + Z₂
println("Total impedance: Z = $Z_total Ω")
println("Magnitude: |Z| = $(abs(Z_total)) Ω")
println("Phase: φ = $(angle(Z_total)) radians = $(rad2deg(angle(Z_total))) degrees")
println()

# 6. Simple Harmonic Motion
println("6. Simple Harmonic Motion")
println("=========================")

# Parameters
ω = 2π    # angular frequency (rad/s)
A = 1.0   # amplitude (m)
φ = 0.0   # phase (rad)

# Position as function of time
x(t) = A * cos(ω * t + φ)

# Calculate position at different times
times = [0, 0.25, 0.5, 0.75, 1.0]
println("Simple harmonic oscillator positions:")
for t_val in times
    println("t = $(t_val) s: x = $(round(x(t_val), digits=3)) m")
end
println()

# 7. Energy Conservation
println("7. Energy Conservation Example")
println("==============================")

# Pendulum energy
function pendulum_energy(θ, θ_dot, m, L, g)
    # θ: angle from vertical (rad)
    # θ_dot: angular velocity (rad/s)
    # m: mass (kg)
    # L: length (m)
    # g: gravitational acceleration (m/s²)
    
    # Kinetic energy
    KE = 0.5 * m * (L * θ_dot)^2
    
    # Potential energy (taking bottom as reference)
    PE = m * g * L * (1 - cos(θ))
    
    return KE, PE, KE + PE
end

# Example: pendulum at different positions
m, L, g = 1.0, 1.0, 9.81
positions = [(π/6, 0.0), (0.0, 1.0), (-π/6, 0.0)]  # (angle, angular_velocity)

println("Pendulum energy analysis:")
for (i, (θ, θ_dot)) in enumerate(positions)
    KE, PE, E_total = pendulum_energy(θ, θ_dot, m, L, g)
    println("Position $i: KE = $(round(KE, digits=3)) J, PE = $(round(PE, digits=3)) J, Total = $(round(E_total, digits=3)) J")
end
println()

# 8. Matrix Operations (useful for quantum mechanics, rotations, etc.)
println("8. Matrix Operations")
println("====================")

# 2D rotation matrix
θ_rot = π/4  # 45 degrees
R = [cos(θ_rot) -sin(θ_rot); sin(θ_rot) cos(θ_rot)]

println("2D rotation matrix (45°):")
println(R)

# Rotate a vector
original_vector = [1.0, 0.0]
rotated_vector = R * original_vector

println("Original vector: $original_vector")
println("Rotated vector: $rotated_vector")
println()

# 9. Statistical Analysis
println("9. Statistical Analysis")
println("=======================")

# Generate some "experimental" data with noise
true_values = sin.(0:0.1:2π)
noise = 0.1 * randn(length(true_values))  # Gaussian noise
measured_values = true_values + noise

# Calculate statistics
mean_val = sum(measured_values) / length(measured_values)
variance = sum((measured_values .- mean_val).^2) / (length(measured_values) - 1)
std_dev = sqrt(variance)

println("Statistical analysis of noisy data:")
println("Mean: $(round(mean_val, digits=4))")
println("Standard deviation: $(round(std_dev, digits=4))")
println("Number of data points: $(length(measured_values))")
println()

println("=== End of Basic Physics Examples ===")
println("\nNext steps:")
println("1. Try modifying the parameters in these examples")
println("2. Run 'julia 02_plotting_examples.jl' for visualization examples")
println("3. Explore the differential equations examples")