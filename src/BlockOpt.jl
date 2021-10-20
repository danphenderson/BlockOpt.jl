module BlockOpt


import Base: @kwdef

include("util.jl")
include("abstract/types.jl")
include("record.jl")
include("model.jl")
include("options.jl")
include("driver.jl")
include("trace.jl")
include("backend.jl")
include("simulation.jl")


"""
    optimize(model::AbstractModel, driver::AbstractDriver)

Solve the program given by the `model` subject to the `driver`.
"""
optimize(model::Model{T, S}, driver::Driver) where {T, S} = solve!(Simulation(model, driver))


"""
    optimize(model::AbstractModel, driver::AbstractDriver)

Solve for an unconstrained minimizer of ``f``. 
"""
optimize(f::Function, ∇f::Function, x₀::S) where {S} = optimize(Model{eltype(S), S}(f, ∇f, x₀), Driver())


end # module