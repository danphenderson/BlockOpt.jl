@enum LogLevel::Int INFO DEBUG WARN ERROR


@enum WeaveLevel::Int NONE ALL


"""
    DriverOptions

Specifies Driving parameters used in a `Simulation` instance.
"""
mutable struct DriverOptions
    samples::Int
    Δ_max::Float64
    δ_tol::Float64
    ϵ_tol::Float64
    max_iterations::Int
    log_level::LogLevel
    weave_level::WeaveLevel

    function DriverOptions(;
        samples = 6, # 2w 
        Δ_max = 100,
        δ_tol = 1.0e-12,
        ϵ_tol = 1e-5,
        max_iterations = 2000,
        log_level = INFO,
        weave_level = ALL,
    )
        new(samples, Δ_max, δ_tol, ϵ_tol, max_iterations, log_level, weave_level)
    end
end


"""
    samples(o::DriverOptions)

The number of hessian samples taken at each succussful step in a simulation. 
"""
samples(o::DriverOptions) = getfield(o, :samples)


"""
    Δ_max(o::DriverOptions)

The maximum trust-region radius of a driven simulation.
"""
Δ_max(o::DriverOptions) = getfield(o, :Δ_max)


"""
    δ_tol(o::DriverOptions)

The relative tolerance passed to `pinv` while performing a block QN update.
"""
δ_tol(o::DriverOptions) = getfield(o, :δ_tol)


"""
    ϵ_tol(o::DriverOptions)

The absolute convergence tolerance, occuring at ``xₖ`` such that ``||∇f(xₖ)|| ≤ ϵ``.
"""
ϵ_tol(o::DriverOptions) = getfield(o, :ϵ_tol)


"""
    max_iterations(o::DriverOptions)

The maximum number of iterations for a driven simulation.
"""
max_iterations(o::DriverOptions) = getfield(o, :max_iterations)


"""
    weave_level(o::DriverOptions) 

Returns the current weave level of a simulation.
"""
weave_level(o::DriverOptions) = getfield(o, :weave_level)


"""
    log_level(o::DriverOptions)

Returns the current logging level of a simulation
"""
log_level(o::DriverOptions) = getfield(o, :log_level)


"""
    samples!(o::DriverOptions, s)

Set the number of hessian samples collected during each succussful step
to some even natrual `s` where ``s = 2w``.
"""
samples!(o::DriverOptions, s) = begin
    mod(s, 2) ≡ 0 && s > 0 && setfield!(o, :samples, s)
    samples(o)
end


"""
    δ_tol!(o::DriverOptions, δ)

Set the maximum trust-region radius to some positive Δ.
"""
Δ_max!(o::DriverOptions, Δ) = begin
    Δ > 0 && setfield!(o, :Δ_max, Δ)
    Δ_max(o)
end


"""
    δ_tol!(o::DriverOptions, δ)

Set the `pinv` relative tolerance used in the QN update to some positive `δ`.
"""
δ_tol!(o::DriverOptions, δ) = begin
    δ > 0 && setfield!(o, :δ_tol, δ)
    δ_tol(o)
end


"""
    ϵ_tol!(o::DriverOptions, ϵ)

Set the terminal convergence tolerance to some positive `ϵ`.
"""
ϵ_tol!(o::DriverOptions, ϵ) = begin
    ϵ > 0 && setfield!(o, :ϵ_tol, ϵ)
    ϵ_tol(o)
end


"""
    max_iterations!(o::DriverOptions, K)

Set the terminal iteration to the positive integer `K`.
"""
max_iterations!(o::DriverOptions, K) = begin
    K ≥ 0 && setfield!(o, :max_iterations, K)
    max_iterations(o)
end


"""
    weave_level!(o::DriverOptions, level::WeaveLevel)

Set the weave level to `NONE` or `ALL`, toggiling the optional `Weave.jl`
generated report of a simulation.
"""
weave_level!(o::DriverOptions, level::WeaveLevel) = setfield!(o, :weave_level, level)



"""
    log_level!(o::DriverOptions, level::LogLevel)

Assign the simulation logging level to `INFO`, `DEBUG`, `WARN`, or `ERROR`.
"""
log_level!(o::DriverOptions, level::LogLevel) = setfield!(o, :log_level, level)


Base.getproperty(o::DriverOptions, s::Symbol) = @restrict DriverOptions


Base.propertynames(o::DriverOptions) = ()