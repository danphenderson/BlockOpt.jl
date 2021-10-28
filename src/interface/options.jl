export samples, backend, Δ_max, δ_tol, ϵ_tol, max_iterations, weave_level, log_level
export samples!, backend!, Δ_max!, δ_tol!, ϵ_tol!, max_iterations!, weave_level!, log_level! 


"""
    AbstractDriverOptions

Defines the interfaced base type for options of an `AbstractDriver`.

# Implements:
    Accesors:
        samples
        Δ_max
        δ_tol
        ϵ_tol
        max_iterations
    Mutators:
        samples!
        Δ_max!
        δ_tol!
        ϵ_tol!
        max_iterations!
"""
abstract type AbstractDriverOptions end


"""
    samples(o::AbstractDriverOptions)
"""
samples(o::AbstractDriverOptions) = @contract AbstractDriverOptions :samples


"""
    samples!(o::AbstractDriverOptions, samples::Int)
"""
samples!(o::AbstractDriverOptions, samples::Int) = @contract AbstractDriverOptions :samples!

"""
    samples(o::AbstractDriverOptions)
"""
backend(o::AbstractDriverOptions) = @contract AbstractDriverOptions :backend


"""
    samples!(o::AbstractDriverOptions, samples::Int)
"""
backend!(o::AbstractDriverOptions, backend::Symbol) = @contract AbstractDriverOptions :backend!


"""
    Δ_max(o::AbstractDriverOptions)
"""
Δ_max(o::AbstractDriverOptions) = @contract AbstractDriverOptions :Δ_max


"""
    Δ_max!(o::AbstractDriverOptions, Δ_max::Float64)
"""
Δ_max!(o::AbstractDriverOptions, Δ_max::Float64) = @contract AbstractDriverOptions :Δ_max!


"""
    δ_tol(o::AbstractDriverOptions)
"""
δ_tol(o::AbstractDriverOptions) = @contract AbstractDriverOptions :δ_tol


"""
    δ_tol!(o::AbstractDriverOptions, δ_tol::Float64)
"""
δ_tol!(o::AbstractDriverOptions, δ_tol::Float64) = @contract AbstractDriverOptions :δ_tol!


"""
    ϵ_tol(o::AbstractDriverOptions)
"""
ϵ_tol(o::AbstractDriverOptions) = @contract AbstractDriverOptions :ϵ_tol


"""
    ϵ_tol!(o::AbstractDriverOptions, ϵ_tol::Float64)
"""
ϵ_tol!(o::AbstractDriverOptions, ϵ_tol) = @contract AbstractDriverOptions :ϵ_tol!


"""
    max_iterations(o::AbstractDriverOptions)
"""
max_iterations(o::AbstractDriverOptions) = @contract AbstractDriverOptions :max_iterations


"""
    max_iterations!(o::AbstractDriverOptions, N::Int)
"""
max_iterations!(o::AbstractDriverOptions, N) = @contract AbstractDriverOptions :max_iterations!


"""
    trace_level(o::AbstractDriverOptions)
"""
weave_level(o::AbstractDriverOptions) = @contract AbstractDriverOptions :weave_level


"""
    trace_level!(o::AbstractDriverOptions, level::Int)
"""
weave_level!(o::AbstractDriverOptions, level) = @contract AbstractDriverOptions :weave_level!


"""
    log_level!(o::AbstractDriverOptions, level::Int)
"""
log_level!(o::AbstractDriverOptions, level) = @contract AbstractDriverOptions :log_level!
