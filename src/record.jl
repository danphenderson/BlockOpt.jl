import .Abstract: AbstractModelRecord, log, log!

"""
    ModelRecord <: AbstractModelRecord

    Holds a record of a model throughout it's life. 
"""
@kwdef mutable struct ModelRecord <: AbstractModelRecord
    log = Vector{Path}()
end


Base.show(io, r::ModelRecord) = show(io, getfield(r, :log))


log(r::ModelRecord) = getfield(r, :log)


log!(r::ModelRecord, p) = append!(log(r), p)