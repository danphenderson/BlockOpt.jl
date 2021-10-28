module BlockOpt


import Base: @kwdef

using LinearAlgebra

import ForwardDiff: Dual, value


include("util.jl")


include("interface/types.jl")


include("lib/types.jl")


optimize(f::Function, ∇f::Function, x₀::S) where {S} = optimize(Model{eltype(S), S}(f, ∇f, x₀), Driver())


end # module