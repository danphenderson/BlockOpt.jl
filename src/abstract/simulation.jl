"""
        AbstractSimulation

    Abstract supertype for delegating the composed behavior of `AbstractModel`
    and `AbstractDriver`, which delegate the behavior of `AbstractRecord` and
    `AbstractOptions`. An `AbstractSimulation` concrete subtype holds the 
    memory representing a Abstractsimulation `State`. 

    ## Interface Contract
    A subtype of AbstractSimulation implements required methods:
        [`model`](@ref)
        [`driver`](@ref)
        [`backend`](@ref)

    
   ## Example
   See: [`AbstractSimulation`](@ref)
"""
abstract type AbstractSimulation end


"""
    model(s::AbstractSimulation)::Model
"""
model(s::AbstractSimulation)::AbstractModel = @contract AbstractSimulation :model


"""
    driver(s::AbstractSimulation)::AbstractDriver
"""
driver(s::AbstractSimulation)::AbstractDriver = @contract AbstractSimulation :driver


"""
    backend(s::AbstractSimulation)::AbstractDriver
"""
backend(s::AbstractSimulation)::AbstractDriver = @contract AbstractSimulation :backend


"""
    load_Abstractsimulation

    Copies information from model and driver into Abstractsimulation.

    Also, responsible for ensuring the problem is well-formed for the
    specified backend.
"""
function _load_simulation(s::AbstractSimulation) 
    # check backend from backend(s)

    # 

end

"""
    simulate!
"""
function simulate! end