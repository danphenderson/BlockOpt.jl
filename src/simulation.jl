"""
Simulation

Enty point and exit point of an iteration. A simulation composes a iterations trace and
backend iteration of Algorithm 7.1.  An instance of a simulation is returned from an
`optimize` call. 
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


model(s::Simulation) = model(trace(s))


driver(s::Simulation) = driver(trace(s))


"""
    trs_timer(s::Simulation)

The elapsed time simulation `s` has spent in `trs_solve(s)`.
"""
trs_timer(s::Simulation) = trs_timer(trace(s))


"""
    trs_counter(s::Simulation)

The count of trust region subproblem subsolves of simulation `s`.
"""
trs_counter(s::Simulation) = trs_counter(trace(s))


"""
    ghs_timer(s::Simulation)

The elapsed time simulation `s` has spent in `gHS(s)`.
"""
ghs_timer(s::Simulation) = ghs_timer(trace(s))


"""
    ghs_counter(s::Simulation)

The number of `gHS` evaluations of simulation `s`.
"""
ghs_counter(s::Simulation) = ghs_counter(trace(s))


weave!(s::Simulation, field, val) = weave!(trace(s), field, val)


weave_level(s::Simulation) = weave_level(trace(s))


"""
    f_vals(s::Simulation)

A vector storing objective values ``f(xₖ)`` for each iterate ``xₖ``.
"""
f_vals(s::Simulation) = f_vals(trace(s))

"""
    ∇f_norms(s::Simulation)

A vector storing normed gradient values ``||∇f(xₖ)||₂`` for each iterate ``xₖ``.
"""
∇f_norms(s::Simulation) = ∇f_norms(trace(s))

"""
    p_norms(s::Simulation)

A vector storing the distance of each successful step ``||pₖ||₂``. 
"""
p_norms(s::Simulation) = p_norms(trace(s))


"""
    Δ_vals(s::Simulation)

A vector storing the trust-region radius passed to `trs_small` of TRS.jl,
during each succussful trust-region subproblem solve. 
"""
Δ_vals(s::Simulation) = Δ_vals(trace(s))


"""
    ρ_vals(s::Simulation)

A vector storing the ratio of actual reduction to model reduction of
each successful step.
"""
ρ_vals(s::Simulation) = ρ_vals(trace(s))


"""
    weave(args::Simulation...)

Generates a Weave.jl report of the simulation args. 
"""
function weave(args::Simulation...)
    println(pwd())
    Weave.weave(
        "src/lib/trace.jmd";
        args = args,
        out_path = mkpath(
            joinpath(directory(model(first(args))), "trace_$(trunc(now(), Minute))"),
        ),
    )
end


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

"""
    initialize(s::Simulation)

Performs each step up to the preliminary update
to obtain ``H₀``. Lines 1-6 of `Algorithm 7.1`.
"""
function initialize(s::Simulation)

    initialize(backend(s))

    increment!(ghs_counter(s))

    weave!(s, f_vals, fₖ(s))

    weave!(s, ∇f_norms, ∇fₖ_norm(s))

    weave!(s, Δ_vals, Δₖ(s))

    info!(s, "Simulating:", s)

    nothing
end


"""
    terminal(s::Simulation)

True if the state of `s` is terminal.
"""
function terminal(s::Simulation)
    if terminal(backend(s), evaluations(trs_counter(s)))
        return true
    end

    return false
end


"""
    build_trs(s::Simulation)

Build arguments for the trs_small call to TRS.jl.
"""
function build_trs(s::Simulation)

    build_trs(backend(s))

    nothing
end


"""
    solve_trs(s::Simulation)

Solve ``aₖ`` in Equation (5.5).
"""
function solve_trs(s::Simulation)

    on!(trs_timer(s))

    solve_trs(backend(s))

    off!(trs_timer(s))

    increment!(trs_counter(s))

    nothing
end


"""
    build_trial(s::Simulation)

Build trial iterate, evaluate the objective at trial location, and compute ``ρ``.
"""
function build_trial(s::Simulation)

    build_trial(backend(s))

    nothing
end


"""
    update_Δₖ(s::Simulation)

Updates the radius Δₖ after each trust-region subproblem solve.
"""
function update_Δₖ(s::Simulation)

    update_Δₖ(backend(s))

    nothing
end


"""
    accept_trial(s::Simulation)

Observes the value of ``ρ``, accepts positive values and updates ``xₖ`` & ``fₖ``.
"""
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


"""
    pflag(s::Simulation)

The preliminary secant update flag of the driver of `s`, default is fale.
"""
function pflag(s::Simulation)
    return pflag(backend(s))
end


"""
    secantQN(s::Simulation)

Performs the standard secant update for `s`'s inverse hessian approximation ``Hₖ``.
"""
function secantQN(s::Simulation)

    secantQN(backend(s))

    nothing
end


"""
    update_Sₖ(s::Simulation)

Updates the ``2w-1`` sample directions of simulation `s`.

See: `S_update_a`, `S_update_b`, `S_update_c`, `S_update_d`, `S_update_e`, `S_update_f`.
"""
function update_Sₖ(s::Simulation)

    update_Sₖ(backend(s))

    nothing
end


"""
    gHS(s::Simulation)

See Algorithm ``3.1``
"""
function gHS(s::Simulation)

    on!(ghs_timer(s))

    gHS(backend(s))

    off!(ghs_timer(s))

    increment!(ghs_counter(s))

    weave!(s, ∇f_norms, ∇fₖ_norm(s))

    nothing
end


"""
    blockQN(s::Simulation)

Performs a block update with multiple descent directions for `s`'s inverse hessian approximation ``Hₖ``.
"""
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

    info!(simulation, "  Terminating:", trace(simulation))

    return simulation
end
