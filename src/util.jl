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