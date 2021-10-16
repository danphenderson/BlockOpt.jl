import .Abstract: AbstractSimulation
import .Abstract: model, driver, backend

"""
    Simulation <: AbstractSimulation 
"""
struct Simulation <: AbstractSimulation 
    model::AbstractModel
    driver::AbstractDriver
    backend::AbstractBackend

    function Simulation(model, driver, backend)
        new(model, driver, backend)
    end
end


model(s::Simulation) = getfield(s, :model)


driver(s::Simulation) = getfield(s, :driver)


backend(s::Simulation) = getfield(s, :backend)


function load_simulation(s::AbstractSimulation) end


function simulate!(m::AbstractModel, d::AbstractDriver) end