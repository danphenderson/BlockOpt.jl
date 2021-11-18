"""
Model

Specifies the unconstrained program for minimizing a smooth objective function.

A model is constructed with a `name` and may be incrementally loaded.
Once a model is loaded, the model becomes final, meaning the objective and gradient
function may no longer be modified. A model creates a directory storing logged 
information throughout the model life. The model's directory is found relative
to the user's current working directory, identified by the models name used as
the relative portion of the directory path.
"""
mutable struct Model
    name::String
    objective::Union{Function,Missing}
    gradient::Union{Function,Missing}
    initial_iterate::Union{AbstractArray,Missing}
    formula::Union{String,Missing}

    dimension::Union{Int,Missing}
    directory::String
    final::Bool

    function Model(
        name::String;
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


"""
    name(m::Model)

Access the name associated with model `m`, as assigned during the construction of `m`.  
"""
name(m::Model) = getfield(m, :name)


"""
    objective(m::Model)

The objective function of model `m`, having an unassigned default value of `missing`.

See `objective!` to load a model's objective.
"""
objective(m::Model) = getfield(m, :objective)


"""
    gradient(m::Model)

The gradient function of model `m`, having an unassigned default value of `missing`.

See `gradient!` to load a `m`'s gradient.
"""
gradient(m::Model) = getfield(m, :gradient)


"""
    initial_iterate(m::Model)

The initial iterate of model `m`, having an unassigned default value of `missing`.
Setting the initial iterate of a model assigns the model a dimension.

See `initial_iterate!` to load `m`'s starting location.
"""
initial_iterate(m::Model) = getfield(m, :initial_iterate)


"""
    formula(m::Model)

The formula of model `m`, having an unassigned default value of `missing`.

See `formula!` to set `m`'s formula.
"""
formula(m::Model) = getfield(m, :formula)


"""
    dimension(m::Model)

The dimension of model `m` which is set by specifying an initial iterate.

See: initial_iterate!
"""
dimension(m::Model) = getfield(m, :dimension)


"""
    directory(m::Model)

The directory path of model `m` holding information related to `m`.
"""
directory(m::Model) = getfield(m, :directory)


"""
    final(m::Model)

The final status of model `m`, occuring when the model's gradient
and objective function are no longer missing. A finalized model may no 
longer modify it's previously defined gradient or objective.
"""
final(m::Model) = getfield(m, :final)


"""
    objective!(m::Model, f)

Assign model `m` the objective function `f`.
    
If the model is final, the `objective!` call simply returns without modifying the model.
"""
objective!(m::Model, f) = !final(m) && begin

    setfield!(m, :final, !isa(gradient(m), Missing))

    setfield!(m, :objective, f)
end


"""
    gradient!(m::Model, ∇f!)

Assign model `m` the in-place gradient function `∇f!`, of the form

```julia
∇f!(out, x) = (out .= ∇f(x))
```

where `∇f(x)` is the steepest descent direction at `x` in stored the place
of the inputed buffer `out`.
    
If the model is final, the `gradient!` call simply returns without modifying the model.
"""
gradient!(m::Model, ∇f!) =
    !final(m) && begin

        setfield!(m, :final, !isa(objective(m), Missing))

        setfield!(m, :gradient, ∇f!)
    end



"""
    initial_iterate!(m::Model, x0)

Assign model `m` an initial iterate.
"""
initial_iterate!(m::Model, x0) = begin

    setfield!(m, :dimension, length(x0))

    setfield!(m, :initial_iterate, x0)
end


"""
    formula!(m::Model, f)

Assign model `m` an escaped ``\\LaTeX`` string represint `m`'s objective function.
The formula is used to create visual plots showing a simulation trace of `m`.

## Example
```julia
julia> dot_formila = "\$ f(x) = x⋅x \$"; 
julia> formula!(m, dot_formila);
```
Here, the euclidean squared distance formula now represent's `m`'s objective formula.
"""
formula!(m::Model, formula) = setfield!(m, :formula, formula)


"""
    obj(m::Model, x)

Evaluate the objective function of model `m` at `x`.
"""
obj(m::Model, x) = begin
    isa(dimension(m), Missing) && return missing
    @lencheck dimension(m) x
    objective(m)(x)
end


"""
    grad!(m::Model, out, x)

Evaluate the in-place gradient function of model `m` at `x`, storing the steepest descent
direction in the place of the passed input buffer `out`.
"""
grad!(m::Model, out, x) = begin
    isa(gradient(m), Missing) && return missing
    @lencheck dimension(m) out x
    return gradient(m)(out, x)
end


"""
    grad(m::Model, x)

Evaluates the gradient function of model `m` at `x`, allocating similar storage
for the output as given by the input `x`.
"""
grad(m::Model, x) = begin
    isa(gradient(m), Missing) && return missing
    @lencheck dimension(m) x
    grad!(m, similar(x), x)
end


"""
    hessAD(m::Model, x)

The dense Hessian matrix of model `m`'s objective function at the point `x`.
The computation uses the `ForwardDiff.jacobian` forward-mode AD routine on the model's 
gradient function.
"""
hessAD(m::Model, x) = begin
    isa(gradient(m), Missing) && return missing
    jacobian(gradient(m), similar(x), x)
end


"""
    hess_sample(m::Model, x, dx)

The hessian vector-product of model `m`'s objective function at the point `x` 
with the vector `dx.` The `gHS` routine uses a more effiecient scheme to compute
the hessian samples with ForwardDiff's `Dual` numbers.
"""
hess_sample(m::Model, x, dx) = begin
    isa(gradient(m), Missing) && return missing
    hessAD(m, x) * dx
end


Base.getproperty(m::Model, s::Symbol) = @restrict Model


Base.propertynames(m::Model) = ()
