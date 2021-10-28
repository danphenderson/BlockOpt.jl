export trace_level, filename, io

"""
AbstractTrace 

Defines the interfaced base type of an optimization simulation trace.

See also: `AbstractSimulation`.

# Implement:
    Accesors:

    Mutators:

"""
abstract type AbstractTrace end


"""
    level(d::AbstractTrace)
"""
level(d::AbstractTrace) = @contract AbstractTrace :level


"""
    io(d::AbstractTrace)
"""
io(t::AbstractTrace) = @contract AbstractTrace :level