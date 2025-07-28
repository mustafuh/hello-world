# Differential Equations in Physics using Julia
# Run this file with: julia 03_differential_equations.jl
# Make sure you have DifferentialEquations.jl installed: 
# julia -e 'using Pkg; Pkg.add("DifferentialEquations"); Pkg.add("Plots")'

using DifferentialEquations, Plots

println("=== Julia for Physicists: Differential Equations ===\n")

# 1. Simple Harmonic Oscillator (2nd order ODE)
println("1. Simple Harmonic Oscillator")
println("=============================")

# The equation: d²x/dt² + ω²x = 0
# We convert this to a system of first-order ODEs:
# dx/dt = v
# dv/dt = -ω²x

function harmonic_oscillator!(du, u, p, t)
    x, v = u
    ω = p[1]
    
    du[1] = v           # dx/dt = v
    du[2] = -ω^2 * x    # dv/dt = -ω²x
end

# Parameters and initial conditions
ω = 2π              # angular frequency
u0 = [1.0, 0.0]     # initial position and velocity [x₀, v₀]
tspan = (0.0, 2.0)  # time span
p = [ω]             # parameters

# Solve the ODE
prob = ODEProblem(harmonic_oscillator!, u0, tspan, p)
sol = solve(prob)

# Plot the solution
p1 = plot(sol, 
          xlabel="Time (s)", 
          ylabel="x, v", 
          title="Simple Harmonic Oscillator",
          label=["Position x(t)" "Velocity v(t)"],
          linewidth=2)

println("   Solved simple harmonic oscillator")

# 2. Damped Harmonic Oscillator
println("2. Damped Harmonic Oscillator")
println("=============================")

# The equation: d²x/dt² + 2γ(dx/dt) + ω₀²x = 0
function damped_oscillator!(du, u, p, t)
    x, v = u
    ω₀, γ = p
    
    du[1] = v                    # dx/dt = v
    du[2] = -2γ*v - ω₀^2 * x    # dv/dt = -2γv - ω₀²x
end

# Different damping scenarios
ω₀ = 2π
damping_cases = [
    (0.5, "Underdamped"),    # γ < ω₀
    (2π, "Critically damped"), # γ = ω₀  
    (4π, "Overdamped")       # γ > ω₀
]

p2 = plot(xlabel="Time (s)", 
          ylabel="Position", 
          title="Damped Harmonic Oscillator")

for (γ, label) in damping_cases
    prob_damped = ODEProblem(damped_oscillator!, u0, tspan, [ω₀, γ])
    sol_damped = solve(prob_damped)
    
    plot!(p2, sol_damped.t, [u[1] for u in sol_damped.u], 
          label=label, linewidth=2)
end

println("   Solved damped oscillator with different damping")

# 3. Simple Pendulum (Nonlinear)
println("3. Simple Pendulum (Nonlinear)")
println("==============================")

# The equation: d²θ/dt² + (g/L)sin(θ) = 0
function pendulum!(du, u, p, t)
    θ, θ̇ = u
    g, L = p
    
    du[1] = θ̇                    # dθ/dt = θ̇
    du[2] = -(g/L) * sin(θ)      # dθ̇/dt = -(g/L)sin(θ)
end

# Parameters
g = 9.81  # gravity
L = 1.0   # pendulum length

# Different initial angles
initial_angles = [π/12, π/6, π/4, π/2]  # 15°, 30°, 45°, 90°
colors = [:blue, :red, :green, :orange]

p3 = plot(xlabel="Time (s)", 
          ylabel="Angle θ (rad)", 
          title="Nonlinear Pendulum")

for (i, θ₀) in enumerate(initial_angles)
    u0_pendulum = [θ₀, 0.0]  # initial angle and angular velocity
    prob_pendulum = ODEProblem(pendulum!, u0_pendulum, (0.0, 5.0), [g, L])
    sol_pendulum = solve(prob_pendulum)
    
    plot!(p3, sol_pendulum.t, [u[1] for u in sol_pendulum.u], 
          label="θ₀ = $(Int(round(rad2deg(θ₀))))°", 
          linewidth=2,
          color=colors[i])
end

println("   Solved nonlinear pendulum for different initial angles")

# 4. Driven Oscillator (Forced vibrations)
println("4. Driven Oscillator")
println("====================")

# The equation: d²x/dt² + 2γ(dx/dt) + ω₀²x = F₀cos(ωt)/m
function driven_oscillator!(du, u, p, t)
    x, v = u
    ω₀, γ, F₀, ω_drive, m = p
    
    du[1] = v                                           # dx/dt = v
    du[2] = -2γ*v - ω₀^2*x + (F₀/m)*cos(ω_drive*t)    # dv/dt = ...
end

# Parameters
m = 1.0      # mass
F₀ = 1.0     # driving force amplitude
γ = 0.1      # damping
ω₀ = 2π      # natural frequency

# Different driving frequencies
drive_frequencies = [0.8*ω₀, ω₀, 1.2*ω₀]  # below, at, above resonance
labels = ["Below resonance", "At resonance", "Above resonance"]

p4 = plot(xlabel="Time (s)", 
          ylabel="Position", 
          title="Driven Oscillator")

for (i, ω_drive) in enumerate(drive_frequencies)
    prob_driven = ODEProblem(driven_oscillator!, [0.0, 0.0], (0.0, 10.0), 
                            [ω₀, γ, F₀, ω_drive, m])
    sol_driven = solve(prob_driven)
    
    plot!(p4, sol_driven.t, [u[1] for u in sol_driven.u], 
          label=labels[i], linewidth=2)
end

println("   Solved driven oscillator at different frequencies")

# 5. Coupled Oscillators
println("5. Coupled Oscillators")
println("======================")

# Two masses connected by springs
# m₁(d²x₁/dt²) = -k₁x₁ + k₂(x₂ - x₁)
# m₂(d²x₂/dt²) = -k₂(x₂ - x₁) - k₃x₂

function coupled_oscillators!(du, u, p, t)
    x₁, v₁, x₂, v₂ = u
    m₁, m₂, k₁, k₂, k₃ = p
    
    du[1] = v₁                                    # dx₁/dt = v₁
    du[2] = (-k₁*x₁ + k₂*(x₂ - x₁)) / m₁         # dv₁/dt = F₁/m₁
    du[3] = v₂                                    # dx₂/dt = v₂
    du[4] = (-k₂*(x₂ - x₁) - k₃*x₂) / m₂         # dv₂/dt = F₂/m₂
end

# Parameters
m₁, m₂ = 1.0, 1.0      # masses
k₁, k₂, k₃ = 1.0, 2.0, 1.0  # spring constants

# Initial conditions: first mass displaced, second at rest
u0_coupled = [1.0, 0.0, 0.0, 0.0]  # [x₁₀, v₁₀, x₂₀, v₂₀]

prob_coupled = ODEProblem(coupled_oscillators!, u0_coupled, (0.0, 10.0), 
                         [m₁, m₂, k₁, k₂, k₃])
sol_coupled = solve(prob_coupled)

p5 = plot(sol_coupled.t, [u[1] for u in sol_coupled.u], 
          label="Mass 1", 
          xlabel="Time (s)", 
          ylabel="Position", 
          title="Coupled Oscillators",
          linewidth=2)

plot!(p5, sol_coupled.t, [u[3] for u in sol_coupled.u], 
      label="Mass 2", linewidth=2)

println("   Solved coupled oscillator system")

# 6. Planetary Motion (Kepler Problem)
println("6. Planetary Motion")
println("===================")

# Newton's law of gravitation in 2D
function planetary_motion!(du, u, p, t)
    x, y, vₓ, vᵧ = u
    GM = p[1]  # gravitational parameter
    
    r = sqrt(x^2 + y^2)
    r³ = r^3
    
    du[1] = vₓ                # dx/dt = vₓ
    du[2] = vᵧ                # dy/dt = vᵧ
    du[3] = -GM * x / r³      # dvₓ/dt = -GMx/r³
    du[4] = -GM * y / r³      # dvᵧ/dt = -GMy/r³
end

# Parameters (using units where G*M_sun = 1)
GM = 1.0

# Initial conditions for elliptical orbit
u0_planet = [1.0, 0.0, 0.0, 0.8]  # [x₀, y₀, vₓ₀, vᵧ₀]

prob_planet = ODEProblem(planetary_motion!, u0_planet, (0.0, 10.0), [GM])
sol_planet = solve(prob_planet)

p6 = plot([u[1] for u in sol_planet.u], [u[2] for u in sol_planet.u], 
          xlabel="x", 
          ylabel="y", 
          title="Planetary Orbit",
          aspect_ratio=:equal,
          linewidth=2,
          label="Planet trajectory")

# Add the sun at origin
scatter!(p6, [0], [0], markersize=8, color=:yellow, label="Sun")

println("   Solved planetary motion (Kepler problem)")

# 7. Lorenz System (Chaos)
println("7. Lorenz System (Chaotic Dynamics)")
println("===================================")

# The Lorenz equations:
# dx/dt = σ(y - x)
# dy/dt = x(ρ - z) - y  
# dz/dt = xy - βz

function lorenz!(du, u, p, t)
    x, y, z = u
    σ, ρ, β = p
    
    du[1] = σ * (y - x)        # dx/dt
    du[2] = x * (ρ - z) - y    # dy/dt
    du[3] = x * y - β * z      # dz/dt
end

# Classic Lorenz parameters
σ, ρ, β = 10.0, 28.0, 8/3

u0_lorenz = [1.0, 1.0, 1.0]  # initial conditions
prob_lorenz = ODEProblem(lorenz!, u0_lorenz, (0.0, 25.0), [σ, ρ, β])
sol_lorenz = solve(prob_lorenz)

# 3D plot of the Lorenz attractor
p7 = plot([u[1] for u in sol_lorenz.u], 
          [u[2] for u in sol_lorenz.u], 
          [u[3] for u in sol_lorenz.u],
          xlabel="x", 
          ylabel="y", 
          zlabel="z",
          title="Lorenz Attractor",
          linewidth=1,
          label="Trajectory")

println("   Solved Lorenz system (chaotic attractor)")

# 8. Wave Equation (PDE solved as system of ODEs)
println("8. Wave Equation")
println("================")

# 1D wave equation: ∂²u/∂t² = c²∂²u/∂x²
# Discretized using finite differences

function wave_equation!(du, u, p, t)
    c, dx, N = p
    
    # u contains [u₁, u₂, ..., uₙ, v₁, v₂, ..., vₙ]
    # where v = ∂u/∂t
    
    # Extract position and velocity arrays
    pos = u[1:N]
    vel = u[N+1:2N]
    
    # Update velocities (du/dt = v)
    du[1:N] = vel
    
    # Update accelerations (dv/dt = c²∂²u/∂x²)
    for i in 2:N-1
        du[N+i] = (c^2 / dx^2) * (pos[i-1] - 2*pos[i] + pos[i+1])
    end
    
    # Boundary conditions (fixed ends)
    du[N+1] = 0.0    # left boundary
    du[2N] = 0.0     # right boundary
end

# Parameters
c = 1.0      # wave speed
L = 1.0      # string length
N = 50       # number of grid points
dx = L / (N-1)

# Initial conditions: plucked string
x_grid = 0:dx:L
u0_wave = zeros(2N)

# Initial displacement (triangular pulse)
for i in 1:N
    if x_grid[i] < L/2
        u0_wave[i] = 2 * x_grid[i] / L
    else
        u0_wave[i] = 2 * (L - x_grid[i]) / L
    end
end
# Initial velocities are zero (already initialized)

prob_wave = ODEProblem(wave_equation!, u0_wave, (0.0, 2.0), [c, dx, N])
sol_wave = solve(prob_wave, saveat=0.1)

# Animate the wave (show a few time snapshots)
p8 = plot(xlabel="Position", 
          ylabel="Displacement", 
          title="1D Wave Equation",
          xlim=(0, L),
          ylim=(-0.6, 0.6))

time_snapshots = [1, 5, 10, 15, 20]
colors = [:blue, :red, :green, :orange, :purple]

for (i, t_idx) in enumerate(time_snapshots)
    if t_idx <= length(sol_wave.t)
        displacement = sol_wave.u[t_idx][1:N]
        plot!(p8, x_grid, displacement, 
              label="t = $(round(sol_wave.t[t_idx], digits=1))", 
              linewidth=2,
              color=colors[i])
    end
end

println("   Solved 1D wave equation")

# Create summary plots
println("\n9. Creating Summary Plots...")

# Combine some plots
summary_plot = plot(p1, p2, p3, p4, 
                   layout=(2,2), 
                   size=(1000, 800),
                   plot_title="Physics Differential Equations")

# Save plots
savefig(p1, "harmonic_oscillator_ode.png")
savefig(p2, "damped_oscillator.png")
savefig(p3, "nonlinear_pendulum.png")
savefig(p4, "driven_oscillator.png")
savefig(p5, "coupled_oscillators.png")
savefig(p6, "planetary_orbit.png")
savefig(p7, "lorenz_attractor.png")
savefig(p8, "wave_equation.png")
savefig(summary_plot, "differential_equations_summary.png")

println("\n=== All differential equations solved successfully! ===")
println("\nGenerated files:")
println("- harmonic_oscillator_ode.png")
println("- damped_oscillator.png")
println("- nonlinear_pendulum.png")
println("- driven_oscillator.png")
println("- coupled_oscillators.png")
println("- planetary_orbit.png")
println("- lorenz_attractor.png")
println("- wave_equation.png")
println("- differential_equations_summary.png")

println("\nKey concepts demonstrated:")
println("1. Converting higher-order ODEs to systems of first-order ODEs")
println("2. Linear vs nonlinear dynamics")
println("3. Damping and driving forces")
println("4. Coupled systems")
println("5. Conservative systems (energy conservation)")
println("6. Chaotic dynamics")
println("7. Partial differential equations as ODE systems")

println("\nNext steps:")
println("1. Try different parameters in these examples")
println("2. Explore different ODE solvers (Runge-Kutta, etc.)")
println("3. Learn about stiff equations and appropriate solvers")
println("4. Study numerical stability and accuracy")

println("\nAdvanced topics to explore:")
println("- Stochastic differential equations (SDEs)")
println("- Delay differential equations (DDEs)")
println("- Boundary value problems (BVPs)")
println("- Parameter estimation and sensitivity analysis")