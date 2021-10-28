

"""
    ModelRecord <: AbstractModelRecord

    Holds a record of a model throughout it's life. 
"""
mutable struct ModelRecord <: AbstractModelRecord
    directory::Union{String, Nothing}
    hasdir::Bool 
    function ModelRecord()
        new(nothing, false)
    end
end


hasdir(r::ModelRecord) = getfield(r, :hasdir)


function directory!(r::ModelRecord, name::String)
    path = joinpath(pwd(), name)
    isdirpath(path) && return nothing
    setfield!(r, :hasrecord, true)
    return setfield!(r, :directory, mkdir(path))
end


directory(r::ModelRecord) = getfield(r, :directory)


Base.getproperty(r::ModelRecord) = @restrict typeof(Model)


Base.propertynames(r::ModelRecord) = ()


function Base.show(io::IO, r::ModelRecord)
    hasdir(r) && println(io, "    Record: $(directory(m))")
    flush(io)
    return nothing
end