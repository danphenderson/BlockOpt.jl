"""
    Backend <: BlockOptType

    Defines the interfaced base type of an optimization simulation backend.
    See also: [`AbstractSimulation`](@ref).

    A subtype of AbstractModelRecord impements:
        [``](@ref)
        [``](@ref)

    # TODO: Add reference to implementation
"""
abstract type AbstractBackend <: AbstractBlockOptType end