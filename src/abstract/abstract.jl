module Abstract

"""
    AbstractBlockOptType

    An abstract supertype of all types exported from `BlockOpt.Types` module of
    the `BlockOpt.jl` package.

    Subtypes of `AbstractBlockOptType` are given a set of traits, see [`AbstractTrait`](@ref).
"""
abstract type AbstractBlockOptType end

include("util.jl")

#include("traits.jl")

include("record.jl")

include("model.jl")

include("options.jl")

include("driver.jl")

include("trace.jl")

include("backend.jl")

include("simulation.jl")

end # Module 