"""
    DimensionError <: Exception
    DimensionError(name, dim_expected, dim_found)

    Error for unexpected dimension.
    Output: "DimensionError: Input `name` should have length `dim_expected` not `dim_found`"
    
    ## From NLPModels.jl
"""
struct DimensionError <: Exception
    name::Union{Symbol,String}
    dim_expected::Int
    dim_found::Int
end


function Base.showerror(io::IO, e::DimensionError)
    print(
        io,
        "DimensionError: Input $(e.name) should have length $(e.dim_expected) not $(e.dim_found)",
    )
end


# https://groups.google.com/forum/?fromgroups=#!topic/julia-users/b6RbQ2amKzg
# https://github.com/JuliaSmoothOptimizers/NLPModels.jl
"""
    @lencheck n x y z …

    Check that arrays `x`, `y`, `z`, etc. have a prescribed length `n`.
"""
macro lencheck(l, vars...)
    exprs = Expr[]
    for var in vars
        varname = string(var)
        push!(exprs, :(
            if length($(esc(var))) != $(esc(l))
                throw(DimensionError($varname, $(esc(l)), length($(esc(var)))))
            end
        ))
    end
    Expr(:block, exprs...)
end


"""
    ContractError(abstract_type, behavior) <: Exception

    Occurs when a concrete type of `abstract_type` has not implemented a specified `behavior`
    Output: "SubtypingError: `behavior` is a requirement of `abstract_type` contract"
"""
struct ContractError <: Exception
    abstract_type::Type
    behavior::Symbol
end


function Base.showerror(io::IO, e::ContractError)
    print(
        io,
        "ContractError: $(e.behavior) is a requirement of $(e.abstract_type) contract!",
    )
end


"""
    @contract abstract_type :behavior

    Declare symbol `:behavior` is a hard-contract requirement of `abstract_type`.
"""
macro contract(abstract_type, behavior)
    return :(throw(ContractError($(esc(abstract_type)), $(esc(behavior)))))
end


"""
    AccessError(type) <: Exception
    
    Output: "AccessError: `:type` restricts field access
"""
struct AccessError <: Exception
    type::Type
end


function Base.showerror(io::IO, e::AccessError)
    print(io, "AccessError: $(e.type) restricts field access")
end


"""
@restrict T::Type 

Restricts field access of type `T` by overloading `Base.getproperty` as:

```julia
Base.getproperty(T, s) = @restrict typeof(T) s
```

then accessing fields of `T` throws an `AccessError`.
"""
macro restrict(type)
    return :(throw(AccessError($(esc(type)))))
end


# """
# _parse_type(table::Dict{Symbol, Any}, T::Type, instance)

# Stores symbol, value pairs consisting of field symbols of `T` and the value
# stored at `instance<:T`.
# """
# function _parse_type!(table::Dict{Symbol, Any}, T::Type, instance)
#     if instance isa T
#         for field in fieldnames(T)
#             table[field] = getfield(m, field) 
#         end
#     end
#     return nothing
# end
