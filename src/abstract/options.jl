"""
    AbstractDriverOptions <: AbstractBlockOptType

    Defines the interfaced base type for options of an [`AbstractDriver`](@ref).

    # TODO: Add reference to implementation 
"""
abstract type AbstractDriverOptions <: AbstractBlockOptType end


"""
    samples(o::AbstractDriverOptions)
"""
samples(o::AbstractDriverOptions) = @contract AbstractDriverOptions :samples


"""
    samples!(o::AbstractDriverOptions, samples::Int)
"""
samples!(o::AbstractDriverOptions, samples::Int) = @contract AbstractDriverOptions :samples!


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
    max_iterations!(o::AbstractDriverOptions, m::Int)
"""
max_iterations!(o::AbstractDriverOptions, m) = @contract AbstractDriverOptions :max_iterations!
