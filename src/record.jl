

"""
    ModelRecord <: AbstractModelRecord

    Holds a record of a model throughout it's life. 
"""
@kwdef mutable struct ModelRecord <: AbstractModelRecord
    log = Vector{String}()
end

log(r::ModelRecord) = getfield(r, :log)


log!(r::ModelRecord, p) = append!(log(r), p)