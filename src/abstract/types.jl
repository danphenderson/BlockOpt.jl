export optimize


"""
    AbstractBlockOptType

An abstract supertype of the BlockOpt.jl components.

Subtypes of `AbstractBlockOptType` can be given a set of traits, see `AbstractTrait`.
"""
abstract type AbstractBlockOptType end


include("record.jl") 
include("model.jl")
include("options.jl")
include("driver.jl")
include("trace.jl")
include("backend.jl")
include("simulation.jl")


"""
optimize(model::AbstractModel{T, S}, driver::AbstractDriver) where {T, S}

Solve the program given by the `model` subject to the `driver`.
"""
function optimize(model::AbstractModel{T, S}, driver::AbstractDriver) where {T, S} end
