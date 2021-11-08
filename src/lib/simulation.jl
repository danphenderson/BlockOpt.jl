export optimize
export PSB, SR1
export S_update_a, S_update_b, S_update_c, S_update_d, S_update_e, S_update_f


"""
Simulation(model::Model, driver::Driver)

Enty point and exit point of an iteration.
"""
struct Simulation
    trace::BlockOptTrace
    backend::BlockOptBackend

    function Simulation(model::Model, driver::Driver)
        # TODO: confrim valid inputs for model and driver 
        new(BlockOptTrace(model, driver), BlockOptBackend(model, driver))
    end
end


Base.getproperty(s::Simulation) = @restrict typeof(Simulation)


Base.propertynames(s::Simulation) = ()


trace(s::Simulation) = getfield(s, :trace)


trs_timer(s::Simulation) = trs_timer(trace(s))


trs_counter(s::Simulation) = trs_counter(trace(s))


ghs_timer(s::Simulation) = ghs_timer(trace(s))


ghs_counter(s::Simulation) = ghs_counter(trace(s))


weave!(s::Simulation, field, val) = weave!(trace(s), field, val)


backend(s::Simulation) = getfield(s, :backend)


fₖ(s::Simulation) = fₖ(backend(s)) 


∇fₖ_norm(s::Simulation) = ∇fₖ_norm(backend(s)) 


pₖ_norm(s::Simulation) = pₖ_norm(backend(s)) 


Δₖ(s::Simulation) = Δₖ(backend(s))


pₖ(s::Simulation) = pₖ(backend(s))


ρ(s::Simulation) = ρ(backend(s))

function Base.show(io::IO, s::Simulation)
    show(trace(s))
    show(backend(s))
    return nothing
end


function initialize(s::Simulation)
    #increment!(ghs_counter(s))
    initialize(backend(s))
    weave!(s, :f_vals, fₖ(s))
    weave!(s, :∇f_norms, ∇fₖ_norm(s))
    weave!(s, :Δ_vals, Δₖ(s))
end


function terminal(s::Simulation)
    # TODO: add monitor for conditioning and underflow
    # Use enum, subject to overhaul
    terminal(backend(s), current_count(trs_counter(s)))
end


"""
Build arguments for the trs_small call
"""
function build_trs(s::Simulation)
    build_trs(backend(s))
end


function solve_trs(s::Simulation)
    increment!(trs_counter(s))
    solve_trs(backend(s))
end


function build_trial(s::Simulation)
    build_trial(backend(s))
end


function update_Δₖ(s::Simulation)
    update_Δₖ(backend(s))
end


function accept_trial(s::Simulation)
    if accept_trial(backend(s))
        weave!(s, :Δ_vals, Δₖ(s))
        weave!(s, :p_norms, pₖ_norm(s))
        weave!(s, :ρ_vals, ρ(s))
        return true
    end
    return false
end


function pflag(s::Simulation)
    pflag(backend(s))
end


function secantQN(s::Simulation)
    secantQN(backend(s))
end


function update_Sₖ(s::Simulation)
    update_Sₖ(backend(s))
end


function gHS(s::Simulation)
    #increment!(ghs_counter(s))
    gHS(backend(s))
end


function blockQN(s::Simulation)
    blockQN(backend(s))
end


function optimize!(simulation::Simulation)
    initialize(simulation)

    build_trs(simulation) 

    while !terminal(simulation)

        solve_trs(simulation)

        build_trial(simulation)

        if accept_trial(simulation)

            if pflag(simulation)
                secantQN(simulation) 
            end

            update_Sₖ(simulation)

            gHS(simulation)

            blockQN(simulation)

            build_trs(simulation)
        end

        update_Δₖ(simulation)
    end
    return simulation
end


optimize(model::Model, driver::Driver) = (s = Simulation(model, driver); optimize!(s))