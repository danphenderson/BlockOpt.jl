export optimize

include("record.jl") 

include("model.jl")

include("options.jl")

include("driver.jl")

include("trace.jl")

include("backend.jl")


"""
Simulation(model::AbstractModel, driver::AbstractDriver)

Enty point and exit point of an iteration.
"""
struct Simulation
    backend::AbstractBackend
    function Simulation(model::AbstractModel, driver::AbstractDriver)
        new(build_backend(:typeof(backend(driver)), model, driver))
    end
end


Base.getproperty(s::Simulation) = @restrict typeof(Simulation)


Base.propertynames(s::Simulation) = ()


optimize!(s::Simulation) = optimize!(getfield(Simulation, :backend))


"""
    optimize(model::AbstractModel, driver::AbstractDriver)

Solve the program given by the `model` subject to the `driver`.
"""
optimize(model::AbstractModel, driver::AbstractDriver) = optimize!(Simulation(model, driver))