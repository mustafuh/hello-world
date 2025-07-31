"""
# Physics Visualization Module

This module provides specialized plotting functions for physics simulations and analysis.
All plots are designed to be publication-ready with proper mathematical notation,
units, and scientific formatting.

## Features

- Yukawa potential visualization with comparison to Coulomb
- Quantum wavefunction plotting with probability densities
- Scattering phase shift and cross section plots
- Classical trajectory visualization
- Interactive 3D surface plots
- Animation capabilities for time evolution
- LaTeX mathematical notation support

## Plot Types

1. **Potential Plots**: V(r) with effective potential
2. **Wavefunction Plots**: ψ(r) and |ψ(r)|²
3. **Energy Level Diagrams**: Bound states and continuum
4. **Scattering Plots**: Phase shifts and cross sections
5. **Phase Space Plots**: Classical trajectories
6. **Comparison Plots**: Multiple potentials/states

## Design Philosophy

- Publication-ready defaults
- Consistent color schemes for physics
- Proper units and scientific notation
- Interactive capabilities where appropriate
- Export to multiple formats (PNG, PDF, SVG)
"""

using Plots
using PlotlyJS
using LaTeXStrings
using Colors
using ColorSchemes
using Printf

# Set default backend and configure for physics
plotlyjs()

# ============================================================================
# Core Plotting Functions
# ============================================================================

"""
    plot_potential(V::YukawaPotential, r_range=(0.1, 10.0); 
                  compare_coulomb=true, show_effective=false, l=0,
                  title="Yukawa Potential", kwargs...)

Plot the Yukawa potential with optional comparisons and effective potential.

# Arguments
- `V::YukawaPotential`: Potential to plot
- `r_range`: Tuple of (r_min, r_max) for plotting range
- `compare_coulomb`: Whether to overlay Coulomb potential
- `show_effective`: Whether to show effective potential with centrifugal barrier
- `l`: Angular momentum quantum number (for effective potential)
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object

# Examples
```julia
V = YukawaPotential(1.0, 1.0, :natural)
p = plot_potential(V, compare_coulomb=true)
```
"""
function plot_potential(V::YukawaPotential, r_range=(0.1, 10.0); 
                       compare_coulomb=true, show_effective=false, l=0,
                       title="Yukawa Potential", kwargs...)
    
    r_min, r_max = r_range
    r = linspace(r_min, r_max, 1000)
    
    # Calculate Yukawa potential
    V_yukawa = [yukawa_potential(V, ri) for ri in r]
    
    # Create base plot
    p = plot(r, V_yukawa, 
             label="Yukawa V(r)",
             linewidth=3,
             color=:blue,
             title=title,
             xlabel=L"Distance $r$",
             ylabel=L"Potential $V(r)$",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    # Add Coulomb comparison if requested
    if compare_coulomb
        V_coulomb = [coulomb_limit(V, ri) for ri in r]
        plot!(p, r, V_coulomb,
              label="Coulomb limit",
              linewidth=2,
              color=:red,
              linestyle=:dash)
    end
    
    # Add effective potential if requested
    if show_effective && l > 0
        V_eff = [effective_potential(V, ri, l) for ri in r]
        plot!(p, r, V_eff,
              label=L"V_{eff}(r), l=%$l",
              linewidth=2,
              color=:green,
              linestyle=:dot)
    end
    
    # Add zero line for reference
    hline!(p, [0], color=:black, linestyle=:dot, alpha=0.5, label="")
    
    # Format axes
    if r_min > 0
        xlims!(p, r_min, r_max)
    end
    
    return p
end

"""
    plot_wavefunction(ψ::AbstractQuantumState; 
                     show_probability=true, normalize=true,
                     title="Quantum Wavefunction", kwargs...)

Plot quantum mechanical wavefunction with optional probability density.

# Arguments
- `ψ::AbstractQuantumState`: Quantum state to plot
- `show_probability`: Whether to show |ψ(r)|² in addition to ψ(r)
- `normalize`: Whether to normalize the wavefunction
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_wavefunction(ψ::AbstractQuantumState; 
                          show_probability=true, normalize=true,
                          title="Quantum Wavefunction", kwargs...)
    
    r = ψ.r
    ψ_vals = ψ.ψ
    
    # Normalize if requested
    if normalize && !ψ.normalized
        norm = sqrt(trapz(r, abs2.(ψ_vals)))
        ψ_vals = ψ_vals ./ norm
    end
    
    # Create base plot for real part of wavefunction
    p = plot(r, real.(ψ_vals),
             label=L"\mathrm{Re}[\psi(r)]",
             linewidth=2,
             color=:blue,
             title=title,
             xlabel=L"Distance $r$",
             ylabel=L"Wavefunction $\psi(r)$",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    # Add imaginary part if complex
    if any(imag.(ψ_vals) .!= 0)
        plot!(p, r, imag.(ψ_vals),
              label=L"\mathrm{Im}[\psi(r)]",
              linewidth=2,
              color=:red,
              linestyle=:dash)
    end
    
    # Add probability density if requested
    if show_probability
        prob_density = abs2.(ψ_vals)
        plot!(p, r, prob_density,
              label=L"|\psi(r)|^2",
              linewidth=2,
              color=:green,
              alpha=0.8)
    end
    
    # Add zero line
    hline!(p, [0], color=:black, linestyle=:dot, alpha=0.3, label="")
    
    # Add energy information if available
    if !isnan(ψ.energy)
        energy_str = @sprintf("E = %.4f", ψ.energy)
        annotate!(p, [(r[end]*0.7, maximum(real.(ψ_vals))*0.8, energy_str)])
    end
    
    return p
end

"""
    plot_bound_states(bound_states::Vector{BoundState1D}; 
                     offset_energies=true, max_states=5,
                     title="Bound State Wavefunctions", kwargs...)

Plot multiple bound states with energy level offsets.

# Arguments
- `bound_states`: Vector of bound states to plot
- `offset_energies`: Whether to offset wavefunctions by their energy levels
- `max_states`: Maximum number of states to plot
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_bound_states(bound_states::Vector{BoundState1D}; 
                          offset_energies=true, max_states=5,
                          title="Bound State Wavefunctions", kwargs...)
    
    n_states = min(length(bound_states), max_states)
    colors = physics_color_scheme()
    
    # Create base plot
    p = plot(title=title,
             xlabel=L"Distance $r$",
             ylabel=offset_energies ? L"Energy + $\psi(r)$" : L"Wavefunction $\psi(r)$",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    for (i, state) in enumerate(bound_states[1:n_states])
        r = state.r
        ψ = real.(state.ψ)  # Take real part
        
        # Normalize
        norm = sqrt(trapz(r, abs2.(state.ψ)))
        ψ = ψ ./ norm
        
        # Offset by energy if requested
        if offset_energies
            ψ = ψ .+ state.energy
        end
        
        # Plot wavefunction
        plot!(p, r, ψ,
              label="n=$(state.n), E=$(round(state.energy, digits=3))",
              linewidth=2,
              color=colors[i])
        
        # Add energy level line if offsetting
        if offset_energies
            hline!(p, [state.energy], 
                   color=colors[i], 
                   linestyle=:dot, 
                   alpha=0.5, 
                   label="")
        end
    end
    
    return p
end

"""
    plot_scattering_phase_shifts(V::YukawaPotential, k_range, l_max=3;
                                title="Scattering Phase Shifts", kwargs...)

Plot scattering phase shifts as a function of wave number.

# Arguments
- `V::YukawaPotential`: Potential for scattering calculation
- `k_range`: Range of wave numbers to plot
- `l_max`: Maximum angular momentum to include
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_scattering_phase_shifts(V::YukawaPotential, k_range, l_max=3;
                                     title="Scattering Phase Shifts", kwargs...)
    
    k_values = collect(k_range)
    colors = physics_color_scheme()
    
    # Create base plot
    p = plot(title=title,
             xlabel=L"Wave number $k$",
             ylabel=L"Phase shift $\delta_\ell(k)$ [rad]",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    # Calculate and plot phase shifts for each l
    for l in 0:l_max
        δₗ_values = [yukawa_scattering(V, k, l) for k in k_values]
        
        plot!(p, k_values, δₗ_values,
              label="l = $l",
              linewidth=2,
              color=colors[l+1],
              marker=:circle,
              markersize=3)
    end
    
    # Add zero line
    hline!(p, [0], color=:black, linestyle=:dot, alpha=0.5, label="")
    
    return p
end

"""
    plot_cross_section(V::YukawaPotential, k_range; 
                      l_max=10, title="Scattering Cross Section", kwargs...)

Plot total scattering cross section as a function of energy.

# Arguments
- `V::YukawaPotential`: Potential for scattering calculation
- `k_range`: Range of wave numbers
- `l_max`: Maximum angular momentum for cross section sum
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_cross_section(V::YukawaPotential, k_range; 
                           l_max=10, title="Scattering Cross Section", kwargs...)
    
    k_values = collect(k_range)
    σ_values = [scattering_cross_section(V, k, l_max=l_max) for k in k_values]
    
    # Convert to energy for x-axis
    E_values = k_values.^2 ./ 2  # E = k²/(2m) in natural units
    
    # Create plot
    p = plot(E_values, σ_values,
             title=title,
             xlabel=L"Energy $E$",
             ylabel=L"Cross section $\sigma$",
             linewidth=3,
             color=:blue,
             grid=true,
             legend=false,
             dpi=300;
             kwargs...)
    
    return p
end

"""
    plot_potential_comparison(potentials::Vector{YukawaPotential}, 
                             labels::Vector{String}, r_range=(0.1, 10.0);
                             title="Potential Comparison", kwargs...)

Compare multiple Yukawa potentials on the same plot.

# Arguments
- `potentials`: Vector of YukawaPotential objects
- `labels`: Labels for each potential
- `r_range`: Plotting range
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_potential_comparison(potentials::Vector{YukawaPotential}, 
                                  labels::Vector{String}, r_range=(0.1, 10.0);
                                  title="Potential Comparison", kwargs...)
    
    @assert length(potentials) == length(labels) "Must have same number of potentials and labels"
    
    r_min, r_max = r_range
    r = linspace(r_min, r_max, 1000)
    colors = physics_color_scheme()
    
    # Create base plot
    p = plot(title=title,
             xlabel=L"Distance $r$",
             ylabel=L"Potential $V(r)$",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    # Plot each potential
    for (i, (V, label)) in enumerate(zip(potentials, labels))
        V_vals = [yukawa_potential(V, ri) for ri in r]
        
        plot!(p, r, V_vals,
              label=label,
              linewidth=2,
              color=colors[i])
    end
    
    # Add zero line
    hline!(p, [0], color=:black, linestyle=:dot, alpha=0.5, label="")
    
    return p
end

# ============================================================================
# 3D and Surface Plots
# ============================================================================

"""
    plot_potential_surface(V::YukawaPotential, r_range=(0.1, 5.0), θ_range=(0, π);
                          title="Yukawa Potential Surface", kwargs...)

Create a 3D surface plot of the Yukawa potential in spherical coordinates.

# Arguments
- `V::YukawaPotential`: Potential to plot
- `r_range`: Radial range (r_min, r_max)
- `θ_range`: Angular range (θ_min, θ_max)
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object (3D surface)
"""
function plot_potential_surface(V::YukawaPotential, r_range=(0.1, 5.0), θ_range=(0, π);
                               title="Yukawa Potential Surface", kwargs...)
    
    r_min, r_max = r_range
    θ_min, θ_max = θ_range
    
    # Create coordinate grids
    r_vals = linspace(r_min, r_max, 50)
    θ_vals = linspace(θ_min, θ_max, 50)
    
    # Calculate potential on grid
    V_grid = zeros(length(θ_vals), length(r_vals))
    for (i, θ) in enumerate(θ_vals)
        for (j, r) in enumerate(r_vals)
            V_grid[i, j] = yukawa_potential(V, r)
        end
    end
    
    # Create surface plot
    p = surface(r_vals, θ_vals, V_grid,
                title=title,
                xlabel=L"Distance $r$",
                ylabel=L"Angle $\theta$",
                zlabel=L"Potential $V(r)$",
                colorbar=true,
                camera=(45, 30),
                dpi=300;
                kwargs...)
    
    return p
end

"""
    plot_wavefunction_3d(ψ::AbstractQuantumState, l::Int, m::Int;
                        title="3D Wavefunction", kwargs...)

Create a 3D visualization of a quantum wavefunction with angular dependence.

# Arguments
- `ψ::AbstractQuantumState`: Radial wavefunction
- `l::Int`: Angular momentum quantum number
- `m::Int`: Magnetic quantum number
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object (3D surface)
"""
function plot_wavefunction_3d(ψ::AbstractQuantumState, l::Int, m::Int;
                             title="3D Wavefunction", kwargs...)
    
    r_vals = ψ.r
    R_vals = real.(ψ.ψ)  # Radial part
    
    # Create angular grid
    θ_vals = linspace(0, π, 50)
    φ_vals = linspace(0, 2π, 50)
    
    # For visualization, we'll plot |ψ|² in spherical coordinates
    # This is a simplified version - full implementation would need spherical harmonics
    
    # Create coordinate grids
    r_grid = zeros(length(θ_vals), length(r_vals))
    θ_grid = zeros(length(θ_vals), length(r_vals))
    
    for (i, θ) in enumerate(θ_vals)
        for (j, r) in enumerate(r_vals)
            r_grid[i, j] = r
            θ_grid[i, j] = θ
        end
    end
    
    # Calculate wavefunction magnitude (simplified)
    ψ_grid = zeros(length(θ_vals), length(r_vals))
    for (i, θ) in enumerate(θ_vals)
        for (j, r) in enumerate(r_vals)
            # Interpolate radial wavefunction
            R_interp = interpolate_linear(ψ.r, R_vals, r)
            # Simplified angular dependence (would need proper spherical harmonics)
            Y_lm = cos(l * θ)  # Simplified
            ψ_grid[i, j] = abs(R_interp * Y_lm)^2
        end
    end
    
    # Create surface plot
    p = surface(r_grid, θ_grid, ψ_grid,
                title=title,
                xlabel=L"Distance $r$",
                ylabel=L"Angle $\theta$",
                zlabel=L"$|\psi(r,\theta)|^2$",
                colorbar=true,
                camera=(45, 30),
                dpi=300;
                kwargs...)
    
    return p
end

# ============================================================================
# Specialized Physics Plots
# ============================================================================

"""
    plot_energy_levels(bound_states::Vector{BoundState1D}, V::YukawaPotential;
                      r_range=(0.1, 10.0), title="Energy Level Diagram", kwargs...)

Create an energy level diagram showing bound states in the potential.

# Arguments
- `bound_states`: Vector of bound states
- `V::YukawaPotential`: Potential for background
- `r_range`: Range for potential plot
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_energy_levels(bound_states::Vector{BoundState1D}, V::YukawaPotential;
                           r_range=(0.1, 10.0), title="Energy Level Diagram", kwargs...)
    
    r_min, r_max = r_range
    r = linspace(r_min, r_max, 1000)
    
    # Plot potential background
    V_vals = [yukawa_potential(V, ri) for ri in r]
    p = plot(r, V_vals,
             label="Yukawa Potential",
             linewidth=2,
             color=:blue,
             alpha=0.7,
             title=title,
             xlabel=L"Distance $r$",
             ylabel=L"Energy",
             grid=true,
             legend=:topright,
             dpi=300;
             kwargs...)
    
    # Add energy levels
    colors = physics_color_scheme()
    for (i, state) in enumerate(bound_states)
        hline!(p, [state.energy],
               color=colors[i],
               linewidth=3,
               label="n=$(state.n), E=$(round(state.energy, digits=3))")
    end
    
    # Add zero energy line
    hline!(p, [0], color=:black, linestyle=:dash, alpha=0.5, label="E = 0")
    
    return p
end

"""
    plot_phase_space(system::ClassicalSystem, trajectory_data;
                    title="Phase Space Trajectory", kwargs...)

Plot classical phase space trajectory.

# Arguments
- `system`: Classical system
- `trajectory_data`: Time series data of position and momentum
- `title`: Plot title
- `kwargs...`: Additional plot arguments

# Returns
- Plots.Plot object
"""
function plot_phase_space(trajectory_data::Matrix{Float64};
                         title="Phase Space Trajectory", kwargs...)
    
    # Assume trajectory_data is [position, momentum] vs time
    positions = trajectory_data[:, 1]
    momenta = trajectory_data[:, 2]
    
    # Create phase space plot
    p = plot(positions, momenta,
             title=title,
             xlabel=L"Position $q$",
             ylabel=L"Momentum $p$",
             linewidth=2,
             color=:blue,
             grid=true,
             legend=false,
             dpi=300;
             kwargs...)
    
    # Mark initial and final points
    scatter!(p, [positions[1]], [momenta[1]], 
             color=:green, markersize=8, label="Start")
    scatter!(p, [positions[end]], [momenta[end]], 
             color=:red, markersize=8, label="End")
    
    return p
end

# ============================================================================
# Utility Functions for Plotting
# ============================================================================

"""
    interpolate_linear(x_data, y_data, x_interp)

Simple linear interpolation for plotting utilities.
"""
function interpolate_linear(x_data::AbstractVector, y_data::AbstractVector, x_interp::Real)
    if x_interp <= x_data[1]
        return y_data[1]
    elseif x_interp >= x_data[end]
        return y_data[end]
    else
        # Find bracketing indices
        idx = searchsortedfirst(x_data, x_interp) - 1
        idx = clamp(idx, 1, length(x_data)-1)
        
        # Linear interpolation
        t = (x_interp - x_data[idx]) / (x_data[idx+1] - x_data[idx])
        return (1-t) * y_data[idx] + t * y_data[idx+1]
    end
end

"""
    save_plot(p::Plots.Plot, filename::String; formats=[:png, :pdf])

Save plot in multiple formats.

# Arguments
- `p`: Plot to save
- `filename`: Base filename (without extension)
- `formats`: Vector of formats to save (:png, :pdf, :svg, :html)
"""
function save_plot(p::Plots.Plot, filename::String; formats=[:png, :pdf])
    for fmt in formats
        full_filename = "$filename.$fmt"
        savefig(p, full_filename)
        println("Plot saved as: $full_filename")
    end
end

"""
    create_publication_plot(plot_function, args...; 
                          size=(800, 600), dpi=300, kwargs...)

Create a publication-ready plot with standard formatting.

# Arguments
- `plot_function`: Function that creates the plot
- `args...`: Arguments for the plot function
- `size`: Plot size in pixels
- `dpi`: Resolution for saved plots
- `kwargs...`: Additional arguments

# Returns
- Publication-formatted plot
"""
function create_publication_plot(plot_function, args...; 
                                size=(800, 600), dpi=300, kwargs...)
    
    # Set publication defaults
    defaults = create_physics_plot_defaults()
    defaults[:size] = size
    defaults[:dpi] = dpi
    
    # Merge with user kwargs
    plot_kwargs = merge(defaults, Dict(kwargs))
    
    # Create plot
    p = plot_function(args...; plot_kwargs...)
    
    return p
end