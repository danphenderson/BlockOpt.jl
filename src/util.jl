"""
    DimensionError <: Exception
    DimensionError(name, dim_expected, dim_found)

    Error for unexpected dimension.
    Output: "DimensionError: Input `name` should have length `dim_expected` not `dim_found`"
    
    ## From NLPModels.jl
"""
struct DimensionError <: Exception
  name::Union{Symbol, String}
  dim_expected::Int
  dim_found::Int
end


function Base.showerror(io::IO, e::DimensionError)
    print(
      io,
      "DimensionError: Input $(e.name) should have length $(e.dim_expected) not $(e.dim_found)",
    )
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


# https://groups.google.com/forum/?fromgroups=#!topic/julia-users/b6RbQ2amKzg
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
    @contract abstract_type :behavior

    Declare symbol `:behavior` is a hard-contract requirement of `abstract_type`.
"""
macro contract(abstract_type, behavior)
    return :(throw(ContractError($(abstract_type), $(behavior))))
end


"""
    AccessError(abstract_type) <: Exception

    Occurs when a concrete type of `abstract_type` has not implemented a specified `behavior`
    Output: "SubtypingError: `behavior` is a requirement of `abstract_type` contract"
"""
struct AccessError <: Exception
    abstract_type::Type
end


function Base.showerror(io::IO, e::AccessError)
    print(
      io,
      "AccessError: $(e.abstract_type) restricts field access",
    )
end

"""
@restrict abstract_type

Restricts field access of the specified "abstract_type".
"""
macro restrict(abstract_type)
    return :(throw(AccessError($(abstract_type))))
end