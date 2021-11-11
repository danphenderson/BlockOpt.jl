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
        # TODO: Handle ill-formed input
        new(BlockOptTrace(model, driver), BlockOptBackend(model, driver))
    end
end


trace(s::Simulation) = getfield(s, :trace)

trs_timer(s::Simulation) = trs_timer(trace(s))

trs_counter(s::Simulation) = trs_counter(trace(s))

ghs_timer(s::Simulation) = ghs_timer(trace(s))

ghs_counter(s::Simulation) = ghs_counter(trace(s))

weave!(s::Simulation, field, val) = weave!(trace(s), field, val)

weave_level(s::Simulation) = weave_level(trace(s))

f_vals(s::Simulation) = f_vals(trace(s)) 

∇f_norms(s::Simulation) = ∇f_norms(trace(s)) 

p_norms(s::Simulation) = p_norms(trace(s)) 

Δ_vals(s::Simulation) = Δ_vals(trace(s))

ρ_vals(s::Simulation) = ρ_vals(trace(s))

io(s::Simulation) = io(trace(s))

log_level(s::Simulation) = log_level(trace(s))

info!(s::Simulation, args...) = info!(trace(s), args...)

debug!(s::Simulation, args...) = debug!(trace(s), args...)

warn!(s::Simulation, args...) = warn!(trace(s), args...)

error!(s::Simulation, args...) = error!(trace(s), args...)


backend(s::Simulation) = getfield(s, :backend)

fₖ(s::Simulation) = fₖ(backend(s)) 

∇fₖ_norm(s::Simulation) = ∇fₖ_norm(backend(s)) 

pₖ_norm(s::Simulation) = pₖ_norm(backend(s)) 

Δₖ(s::Simulation) = Δₖ(backend(s))

ρ(s::Simulation) = ρ(backend(s))


Base.getproperty(s::Simulation, sym::Symbol) = @restrict Simulation

Base.propertynames(s::Simulation) = ()


function initialize(s::Simulation)

    initialize(backend(s))

    increment!(ghs_counter(s))

    weave!(s, f_vals, fₖ(s))

    weave!(s, ∇f_norms, ∇fₖ_norm(s))

    weave!(s, Δ_vals, Δₖ(s))

    println()

    nothing
end



function terminal(s::Simulation)
    # TODO: add monitor for conditioning and underflow
    #       Use enum, to hold state.

    if terminal(backend(s), evaluations(trs_counter(s)))

        return true

    end

    return false
end


"""
Build arguments for the trs_small call
"""
function build_trs(s::Simulation)

    build_trs(backend(s))

    nothing
end


function solve_trs(s::Simulation)

    on!(trs_timer(s))

    solve_trs(backend(s))

    off!(trs_timer(s))

    increment!(trs_counter(s))

    nothing
end


function build_trial(s::Simulation)

    build_trial(backend(s))

    nothing
end


function update_Δₖ(s::Simulation)

    update_Δₖ(backend(s))

    nothing
end


function accept_trial(s::Simulation)

    if accept_trial(backend(s))

        weave!(s, f_vals, fₖ(s))

        weave!(s, Δ_vals, Δₖ(s))

        weave!(s, p_norms, pₖ_norm(s))

        weave!(s, ρ_vals, ρ(s))

        return true
    end

    return false
end


function pflag(s::Simulation)
    return pflag(backend(s))
end


function secantQN(s::Simulation)

    secantQN(backend(s))

    nothing
end


function update_Sₖ(s::Simulation)

    update_Sₖ(backend(s))

    nothing
end


function gHS(s::Simulation)

    on!(ghs_timer(s))

    gHS(backend(s))

    off!(ghs_timer(s))

    increment!(ghs_counter(s))

    weave!(s, ∇f_norms, ∇fₖ_norm(s))

    nothing
end


function blockQN(s::Simulation)

    blockQN(backend(s))

    nothing
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


optimize(model::Model, driver::Driver) = optimize!(Simulation(model, driver))

