export log, log!


"""
    AbstractModelRecord

Defines the interfaced base type of an optimization model record.

# Implements:
    Mutators:
        log!
    Accesors:
        log
"""
abstract type AbstractModelRecord end


"""
directory(r::AbstractModelRecord)

View the log of record `r`.
"""
directory(r::AbstractModelRecord) = @contract AbstractModelRecord :directory


"""
directory!(r::AbstractModelRecord, p::Path)

Add the log file at path `p` to the record `r`.
"""
directory!(r::AbstractModelRecord, p) = @contract AbstractModelRecord :directory!