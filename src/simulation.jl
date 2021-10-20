"""
    Simulation <: AbstractSimulation 

Enty point and exit point of an iteration.

The `Simulation` is built from `Driver` and `Model` objects, 
and the entry point occurs when calling `simulate!` on the constructed
object. The backend is responsible for terminating the simulation
and logging the `Trace` in the `ModelRecord`.
"""
struct Simulation <: AbstractSimulation 
    model::Model
    driver::Driver

    function Simulation(model::AbstractModel, driver::AbstractDriver)
        new(model, driver)
    end
end


model(s::Simulation) = getfield(s, :model)


driver(s::Simulation) = getfield(s, :driver)


options(s::Simulation) = options(driver(s))


record(s::Simulation) = record(model(s))


"""
    load_simulation

Loads the specified backend. 
"""
function _load_simulation(s::Simulation) 
    m = model(s)
    d = driver(s)
    return eval(
        Expr(:call, backend(d),
            x -> objective(m),
            g, x -> gradient(m),  
            copy(initial_iterate(m)),
            options(s),
            record(s),
            QN_update(d),
            S_update(d)
        )
    )  # todo: wrap in try-catch block
end


solve!(s::Simulation) = solve!(load_simulation(s::Simulation))