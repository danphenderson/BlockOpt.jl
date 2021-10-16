export AbstractTrace

"""
    AbstractTrace

    Defines the interfaced base type of an optimization simulation trace.
    See also: [`AbstractSimulation`](@ref).

    A subtype of AbstractTrace impements:

    # TODO: Add reference to implementation
"""
abstract type AbstractTrace <: AbstractBlockOptType end

"""
    filename(d::AbstractTrace)
"""
filename(t::AbstractTrace) = @contract AbstractTrace :filename


"""
    level(d::AbstractTrace)
"""
level(d::AbstractTrace) = @contract AbstractTrace :level


"""
    _io(d::AbstractTrace)
"""
io(t::AbstractTrace) = @contract AbstractTrace :level