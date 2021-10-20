
"""
    AbstractModelRecord <: AbstractBlockOptType 

Defines the interfaced base type of an optimization model record.

# Implements:
    Mutators:
        log!
    Accesors:
        log
"""
abstract type AbstractModelRecord <: AbstractBlockOptType end


"""
    log(r::AbstractModelRecord)

View the log of record `r`.
"""
log(r::AbstractModelRecord) = @contract AbstractModelRecord :log


"""
    log!(r::AbstractModelRecord, p::Path)

Add the log file at path `p` to the record `r`.
"""
log!(r::AbstractModelRecord, p) = @contract AbstractModelRecord :log!