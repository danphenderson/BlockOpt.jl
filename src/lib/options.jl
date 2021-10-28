export LogLevel, TraceLevel

@enum LogLevel INFO DEBUG WARN ERROR
@enum WeaveLevel NONE ALL

"""
    DriverOptions <:  AbstractDriverOptions    
"""
mutable struct DriverOptions <: AbstractDriverOptions
    samples::Int
    Δ_max::Float64
    δ_tol::Float64
    ϵ_tol::Float64
    max_iterations::Int
    log_level::LogLevel
    weave_level::WeaveLevel

    function DriverOptions(;
        samples = 3,
        Δ_max = 100,
        δ_tol = 1e-12,
        ϵ_tol = 1e-5,
        max_iterations = 2000,
        log_level = INFO,
        weave_level = NONE,
    )
        new(samples, Δ_max, δ_tol, ϵ_tol, max_iterations, log_level, weave_level)
    end 
end


samples(o::DriverOptions) = getfield(o, :samples)


Δ_max(o::DriverOptions) = getfield(o, :Δ_max)


δ_tol(o::DriverOptions) = getfield(o, :δ_tol)


ϵ_tol(o::DriverOptions) = getfield(o, :ϵ_tol)


max_iterations(o::DriverOptions) = getfield(o, :max_iterations)


weave_level(o::DriverOptions) = getfield(o, :weave_level)


log_level(o::DriverOptions) = getfield(o, :log_level)


samples!(o::DriverOptions, s) = setfield!(o, :samples, s)


Δ_max!(o::DriverOptions, Δ) = setfield!(o, :Δ_max, Δ)


δ_tol!(o::DriverOptions, δ) = setfield!(o, :δ_tol, δ)


ϵ_tol!(o::DriverOptions, ϵ) = setfield!(o, :ϵ_tol, ϵ)


max_iterations!(o::DriverOptions, K) = setfield!(o, :max_iterations, K)


weave_level!(o::DriverOptions, level::WeaveLevel) = setfield!(o, :weave_level, level)


log_level!(o::DriverOptions, level::LogLevel) = setfield!(o, :log_level, level)


Base.getproperty(o::DriverOptions) = @restrict typeof(d)


Base.propertynames(o::DriverOptions) = ()


function Base.show(io::IO, o::DriverOptions)
    println(io, "\n    Options:")
    println(io, "    ------------------------------------")
    println(io, "        samples:        $(samples(o))")
    println(io, "        Δ_max:          $(Δ_max(o))")
    println(io, "        δ_tol:          $(δ_tol(o))")
    println(io, "        ϵ_tol:          $(ϵ_tol(o))")
    println(io, "        max iterations: $(max_iterations(o))")
    flush(io)
    return nothing
end