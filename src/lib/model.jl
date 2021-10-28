export Model

"""
    Model{T,S} <: AbstractModel{T, S}    
"""
mutable struct Model{T, S} <: AbstractModel{T, S}
    objective::Union{Function, Missing}
    gradient::Union{Function, Missing}
    dimension::Union{Int, Missing}
    initial_iterate::Union{S, Missing} 
    name::Union{String, Missing}
    formula::Union{String, Missing}
    record::ModelRecord

    function Model{T, S}(
        objective = missing,
        gradient = missing, 
        initial_iterate = missing;
        name = "",
        dimension = missing,
        formula = missing,
    ) where {T, S}
        new{T, S}(
            objective,
            gradient,
            dimension,
            initial_iterate,
            name,
            formula,
            ModelRecord(),
        )
    end 
end


"""
    Model(objective::Function, gradient!::Function, initial_iterate::S; kwargs...)
"""
@inline function Model(objective::Function, gradient::Function, initial_iterate::S; kwargs...) where {S}
    return Model{eltype(S), S}(objective, gradient, initial_iterate; kwargs...)
end


Base.getproperty(m::Model) = @restrict typeof(Model)


Base.propertynames(m::Model) = ()


objective!(m::Model, f::Function) = (setfield!(m, :objective, f); m)


gradient!(m::Model, ∇f!::Function) = (setfield!(m, :gradient, ∇f!); m)


initial_iterate!(m::Model, x0::AbstractArray) = begin
    setfield!(m, :initial_iterate, x0)
    setfield!(m, :dimension, length(x0))
    m
end


name!(m::Model, name::String) = (setfield!(m, :name, name); m)


formula!(m::Model, formula::AbstractString) = (setfield!(m, :formula, formula); m)


objective(m::Model) = getfield(m, :objective)


gradient(m::Model) = getfield(m, :gradient)


initial_iterate(m::Model) = getfield(m, :initial_iterate)


dimension(m::Model) = getfield(m, :dimension)


name(m::Model) = getfield(m, :name)


formula(m::Model) = getfield(m, :formula)


record(m::Model) = getfield(m, :record)


hasdir(m::Model) = hasdir(record(m))


directory(m::Model) = directory(record(m))


function Base.show(io::IO, m::Model)
    println(io, "Model: $(name(m))")
    !isa(formula(m), Missing) && println(io, "$(formula(m))")
    println(io, "----------------------------------------")
    println(io, "    objective:        $(objective(m))")
    println(io, "    gradient:         $(gradient(m))")
    println(io, "    initial iterate:  $(initial_iterate(m))")
    println(io, "    dimension:        $(dimension(m))")
    flush(io)
    return show(record(m))
end