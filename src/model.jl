"""
    Model
"""
mutable struct Model
    name::String
    objective::Union{Function, Missing}
    gradient::Union{Function, Missing}
    initial_iterate::Union{AbstractArray, Missing} 
    formula::Union{String, Missing}
    
    dimension::Union{Int, Missing}
    directory::String
    final::Bool

    function Model(name::String;
        objective = missing,
        gradient = missing, 
        initial_iterate = missing,
        formula = missing,
    )
        dimension = isa(initial_iterate, Missing) ? missing : length(initial_iterate)
        directory = mkpath(joinpath(pwd(), name))
        final = !isa(objective, Missing) && !isa(gradient, Missing)

        new(
            name,
            objective,
            gradient,
            initial_iterate,
            formula,
            dimension,
            directory,
            final,
        )
    end 
end


name(m::Model) = getfield(m, :name)

objective(m::Model) = getfield(m, :objective)

gradient(m::Model) = getfield(m, :gradient)

initial_iterate(m::Model) = getfield(m, :initial_iterate)

formula(m::Model) = getfield(m, :formula)

dimension(m::Model) = getfield(m, :dimension)

directory(m::Model) = getfield(m, :directory)

final(m::Model) = getfield(m, :final)

objective!(m::Model, f) = !final(m) && begin

    setfield!(m, :final, !isa(gradient(m), Missing))

    setfield!(m, :objective, f) 
end

gradient!(m::Model, ∇f!) = !final(m) && begin

    setfield!(m, :final, !isa(objective(m), Missing))

    setfield!(m, :gradient, ∇f!)
end

initial_iterate!(m::Model, x0) = begin

    setfield!(m, :dimension, length(x0))

    setfield!(m, :initial_iterate, x0)
end

formula!(m::Model, formula) = setfield!(m, :formula, formula)

obj(m::Model, x) = begin 
    @lencheck dimension(m) x
    objective(m)(x) 
end

function grad!(m::Model, out, x) 
    @lencheck dimension(m) out x
    return gradient(m)(out, x)
end

grad(m::Model, x) = grad!(m, similar(x), x)

hessAD(model, x) = jacobian(gradient(model), similar(x), x)

hess_sample(model, x, dx) = hessAD(model, x) * dx


Base.getproperty(m::Model, s::Symbol) = @restrict Model

Base.propertynames(m::Model) = ()