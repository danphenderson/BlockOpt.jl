"""
    AbstractTrace <: AbstractBlockOptType

Defines the interfaced base type of an optimization simulation trace.

See also: `AbstractSimulation`.

# Implement:
    Accesors:

    Mutators:

"""
abstract type AbstractTrace <: AbstractBlockOptType end


"""
    trace_level(d::AbstractTrace)
"""
trace_level(d::AbstractTrace) = @contract AbstractTrace :level


"""
    filename(d::AbstractTrace)
"""
filename(t::AbstractTrace) = @contract AbstractTrace :filename


"""
    io(d::AbstractTrace)
"""
io(t::AbstractTrace) = @contract AbstractTrace :level