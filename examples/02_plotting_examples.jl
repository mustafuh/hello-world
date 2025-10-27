# Physics Plotting Examples in Julia
# Run this file with: julia 02_plotting_examples.jl
# Make sure you have Plots.jl installed: julia -e 'using Pkg; Pkg.add("Plots")'

using Plots

println("=== Julia for Physicists: Plotting Examples ===\n")

# Set the plotting backend (GR is fast and works well)
gr()

# 1. Simple Harmonic Oscillator
println("1. Creating Simple Harmonic Oscillator Plot...")

# Parameters
ω = 2π    # angular frequency (rad/s)
A = 1.0   # amplitude (m)
φ = 0.0   # phase (rad)

# Time array
t = 0:0.01:2.0

# Position and velocity
x = A .* cos.(ω .* t .+ φ)
v = -A .* ω .* sin.(ω .* t .+ φ)

# Create the plot
p1 = plot(t, x, 
          label="Position", 
          xlabel="Time (s)", 
          ylabel="Position (m)", 
          title="Simple Harmonic Oscillator",
          linewidth=2,
          color=:blue)

plot!(p1, t, v, 
      label="Velocity", 
      linewidth=2,
      color=:red)

# Save the plot
savefig(p1, "harmonic_oscillator.png")
println("   Saved as: harmonic_oscillator.png")

# 2. Projectile Motion
println("2. Creating Projectile Motion Plot...")

function projectile_motion(v0, θ, g=9.81)
    v0x = v0 * cos(θ)
    v0y = v0 * sin(θ)
    t_flight = 2 * v0y / g
    t = 0:0.01:t_flight
    x = v0x .* t
    y = v0y .* t .- 0.5 * g .* t.^2
    return x, y, t
end

# Different launch angles
angles = [π/6, π/4, π/3]  # 30°, 45°, 60°
colors = [:red, :blue, :green]
v0 = 20.0  # initial speed (m/s)

p2 = plot(xlabel="Range (m)", 
          ylabel="Height (m)", 
          title="Projectile Motion at Different Angles",
          aspect_ratio=:equal)

for (i, θ) in enumerate(angles)
    x, y, t = projectile_motion(v0, θ)
    plot!(p2, x, y, 
          label="$(Int(round(rad2deg(θ))))°", 
          linewidth=2,
          color=colors[i])
end

savefig(p2, "projectile_motion.png")
println("   Saved as: projectile_motion.png")

# 3. Wave Interference
println("3. Creating Wave Interference Plot...")

# Parameters for two waves
λ₁ = 2.0   # wavelength 1
λ₂ = 1.8   # wavelength 2
A₁ = 1.0   # amplitude 1
A₂ = 0.8   # amplitude 2

x = 0:0.01:10
y₁ = A₁ .* sin.(2π .* x ./ λ₁)
y₂ = A₂ .* sin.(2π .* x ./ λ₂)
y_total = y₁ .+ y₂

p3 = plot(x, y₁, 
          label="Wave 1 (λ=$λ₁)", 
          xlabel="Position", 
          ylabel="Amplitude", 
          title="Wave Interference",
          linewidth=2,
          color=:blue,
          linestyle=:dash)

plot!(p3, x, y₂, 
      label="Wave 2 (λ=$λ₂)", 
      linewidth=2,
      color=:red,
      linestyle=:dash)

plot!(p3, x, y_total, 
      label="Superposition", 
      linewidth=3,
      color=:black)

savefig(p3, "wave_interference.png")
println("   Saved as: wave_interference.png")

# 4. Maxwell-Boltzmann Distribution
println("4. Creating Maxwell-Boltzmann Distribution Plot...")

function maxwell_boltzmann(v, m, T)
    k_B = 1.381e-23  # Boltzmann constant
    return 4π * v^2 * (m/(2π*k_B*T))^(3/2) * exp(-m*v^2/(2*k_B*T))
end

# Parameters for different temperatures
m = 4.65e-26  # mass of N₂ molecule (kg)
temperatures = [200, 300, 400]  # K
colors = [:blue, :red, :green]

v = 0:10:1500  # velocity range (m/s)

p4 = plot(xlabel="Speed (m/s)", 
          ylabel="Probability Density", 
          title="Maxwell-Boltzmann Distribution for N₂")

for (i, T) in enumerate(temperatures)
    f_v = maxwell_boltzmann.(v, m, T)
    plot!(p4, v, f_v, 
          label="T = $(T) K", 
          linewidth=2,
          color=colors[i])
end

savefig(p4, "maxwell_boltzmann.png")
println("   Saved as: maxwell_boltzmann.png")

# 5. Quantum Harmonic Oscillator Wavefunctions
println("5. Creating Quantum Harmonic Oscillator Wavefunctions...")

# Hermite polynomials (first few)
function hermite(n, x)
    if n == 0
        return ones(length(x))
    elseif n == 1
        return 2 .* x
    elseif n == 2
        return 4 .* x.^2 .- 2
    elseif n == 3
        return 8 .* x.^3 .- 12 .* x
    else
        error("Only n=0,1,2,3 implemented")
    end
end

# Quantum harmonic oscillator wavefunction
function qho_wavefunction(n, x)
    α = 1.0  # characteristic length scale
    normalization = (α/π)^(1/4) / sqrt(2^n * factorial(n))
    return normalization .* hermite(n, x/α) .* exp.(-x.^2/(2*α^2))
end

x = -4:0.01:4
quantum_numbers = [0, 1, 2, 3]
colors = [:blue, :red, :green, :orange]

p5 = plot(xlabel="Position", 
          ylabel="Wavefunction ψ(x)", 
          title="Quantum Harmonic Oscillator Wavefunctions")

for (i, n) in enumerate(quantum_numbers)
    ψ = qho_wavefunction(n, x)
    plot!(p5, x, ψ, 
          label="n = $n", 
          linewidth=2,
          color=colors[i])
end

savefig(p5, "quantum_harmonic_oscillator.png")
println("   Saved as: quantum_harmonic_oscillator.png")

# 6. Electric Field Lines (2D)
println("6. Creating Electric Field Visualization...")

# Function to calculate electric field
function electric_field_2d(charges, positions, x, y)
    k = 8.99e9  # Coulomb's constant
    Ex = 0.0
    Ey = 0.0
    
    for (q, pos) in zip(charges, positions)
        dx = x - pos[1]
        dy = y - pos[2]
        r = sqrt(dx^2 + dy^2)
        
        if r > 0.1  # Avoid singularity
            E_magnitude = k * q / r^2
            Ex += E_magnitude * dx / r
            Ey += E_magnitude * dy / r
        end
    end
    
    return Ex, Ey
end

# Set up grid
x_range = -3:0.3:3
y_range = -3:0.3:3

# Two opposite charges (dipole)
charges = [1e-9, -1e-9]  # +1 nC and -1 nC
positions = [[-1, 0], [1, 0]]

# Calculate field at each grid point
Ex_grid = zeros(length(x_range), length(y_range))
Ey_grid = zeros(length(x_range), length(y_range))

for (i, x) in enumerate(x_range)
    for (j, y) in enumerate(y_range)
        Ex, Ey = electric_field_2d(charges, positions, x, y)
        Ex_grid[i, j] = Ex
        Ey_grid[i, j] = Ey
    end
end

# Create quiver plot
p6 = quiver(x_range, y_range, 
           quiver=(Ex_grid', Ey_grid'),
           xlabel="x", 
           ylabel="y", 
           title="Electric Field of a Dipole",
           aspect_ratio=:equal)

# Add charge positions
scatter!(p6, [pos[1] for pos in positions], 
             [pos[2] for pos in positions],
             markersize=8,
             color=[:red, :blue],
             label=["Positive", "Negative"])

savefig(p6, "electric_field_dipole.png")
println("   Saved as: electric_field_dipole.png")

# 7. Phase Space Plot (Pendulum)
println("7. Creating Phase Space Plot...")

# Simple pendulum phase space
function pendulum_phase_space(θ₀, θ̇₀, g=9.81, L=1.0, steps=1000)
    dt = 0.01
    θ = zeros(steps)
    θ̇ = zeros(steps)
    
    θ[1] = θ₀
    θ̇[1] = θ̇₀
    
    for i in 2:steps
        # Simple Euler integration (for demonstration)
        θ̈ = -(g/L) * sin(θ[i-1])
        θ̇[i] = θ̇[i-1] + θ̈ * dt
        θ[i] = θ[i-1] + θ̇[i] * dt
    end
    
    return θ, θ̇
end

# Different initial conditions
initial_conditions = [(π/6, 0), (π/4, 0), (π/3, 0), (π/2, 0)]
colors = [:blue, :red, :green, :orange]

p7 = plot(xlabel="Angle θ (rad)", 
          ylabel="Angular Velocity θ̇ (rad/s)", 
          title="Pendulum Phase Space")

for (i, (θ₀, θ̇₀)) in enumerate(initial_conditions)
    θ, θ̇ = pendulum_phase_space(θ₀, θ̇₀)
    plot!(p7, θ, θ̇, 
          label="θ₀ = $(round(θ₀, digits=2))", 
          linewidth=2,
          color=colors[i])
end

savefig(p7, "pendulum_phase_space.png")
println("   Saved as: pendulum_phase_space.png")

# 8. 3D Surface Plot (Potential Well)
println("8. Creating 3D Potential Well Plot...")

# 2D harmonic oscillator potential
x = -3:0.1:3
y = -3:0.1:3
V = [0.5 * (xi^2 + yi^2) for xi in x, yi in y]

p8 = surface(x, y, V, 
            xlabel="x", 
            ylabel="y", 
            zlabel="Potential V(x,y)", 
            title="2D Harmonic Oscillator Potential",
            colorbar=true)

savefig(p8, "potential_well_3d.png")
println("   Saved as: potential_well_3d.png")

# Create a summary plot with subplots
println("9. Creating Summary Plot with Subplots...")

p_summary = plot(p1, p2, p3, p4, 
                layout=(2,2), 
                size=(800, 600),
                plot_title="Physics Examples Summary")

savefig(p_summary, "physics_summary.png")
println("   Saved as: physics_summary.png")

println("\n=== All plots created successfully! ===")
println("\nGenerated files:")
println("- harmonic_oscillator.png")
println("- projectile_motion.png") 
println("- wave_interference.png")
println("- maxwell_boltzmann.png")
println("- quantum_harmonic_oscillator.png")
println("- electric_field_dipole.png")
println("- pendulum_phase_space.png")
println("- potential_well_3d.png")
println("- physics_summary.png")

println("\nTips for customizing plots:")
println("1. Change colors with color=:red, :blue, etc.")
println("2. Modify line styles with linestyle=:dash, :dot, etc.")
println("3. Adjust plot size with size=(width, height)")
println("4. Save in different formats: .png, .pdf, .svg")
println("5. Use different backends: gr(), plotlyjs(), pyplot()")

println("\nNext: Try 'julia 03_differential_equations.jl' for solving physics ODEs!")