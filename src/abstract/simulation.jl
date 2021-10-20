export AbstractSimulation
export record, options, driver, solve!

"""
    AbstractSimulation <: AbstractBlockOptType

Abstract supertype for delegating the composed behavior of `AbstractModel`
and `Abstractdwhich delegate the behavior of `AbstractRecord` and
`AbstractOptions`. An `AbstractSimulation` concrete subtype holds the 
memory representing a Abstractsimulation `State`. 

# Implements:
    Accesors:
        model
        driver
        backend    
    Inherts:
        AbstractModel
        AbstractDriver
        Abstractbackend
"""
abstract type AbstractSimulation <: AbstractBlockOptType end


"""
record(s::AbstractSimulation)
"""
record(s::AbstractSimulation) = record(model(s))


"""
options(s::AbstractSimulation)
"""
options(s::AbstractSimulation) = options(driver(s))


"""
model(s::AbstractSimulation)::Model
"""
model(s::AbstractSimulation)::AbstractModel = @contract AbstractSimulation :model


"""
driver(s::AbstractSimulation)::AbstractDriver
"""
driver(s::AbstractSimulation)::AbstractDriver = @contract AbstractSimulation :driver



"""
solve!(s::AbstractSimulation)
"""
solve!(s::AbstractSimulation) = @contract AbstractSimulation :solve!

