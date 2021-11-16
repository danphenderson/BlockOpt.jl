"""
Timer

Holds a count that is incremented in units of 1. 
"""
mutable struct EvaluationTimer
    Δt::Any

    function EvaluationTimer()
        new(0.0)
    end
end

Δt(t::EvaluationTimer) = getfield(t, :Δt)

on!(t::EvaluationTimer) = setfield!(t, :Δt, Δt(t) - time())

off!(t::EvaluationTimer) = setfield!(t, :Δt, time() + Δt(t))

Base.getproperty(t::EvaluationTimer, s::Symbol) = @restrict EvaluationTimer

Base.propertynames(t::EvaluationTimer) = ()


"""
EvaluationCounter

Holds a count that is incremented in units of 1. 
"""
mutable struct EvaluationCounter
    evaluations::Int

    function EvaluationCounter()
        new(0)
    end
end

evaluations(c::EvaluationCounter) = getfield(c, :evaluations)

increment!(c::EvaluationCounter, units = 1) = begin
    units > 0 && setfield!(c, :evaluations, evaluations(c) + units)
    return evaluations(c)
end


Base.getproperty(t::EvaluationCounter, s::Symbol) = @restrict EvaluationCounter

Base.propertynames(t::EvaluationCounter) = ()


"""
BlockOptProfile

Holds a count of the trust region subproblem solves and gHS evaluations.

## Development
```md
- Profile should include allocations, increment! by units of allocations
- Generate fields, i.e. counters, timers from simulation units of algorithm 7.1
```
"""
struct BlockOptProfile
    trs_timer::EvaluationTimer
    trs_counter::EvaluationCounter
    ghs_timer::EvaluationTimer
    ghs_counter::EvaluationCounter

    function BlockOptProfile()
        new(EvaluationTimer(), EvaluationCounter(), EvaluationTimer(), EvaluationCounter())
    end
end


trs_timer(p::BlockOptProfile) = getfield(p, :trs_timer)

trs_counter(p::BlockOptProfile) = getfield(p, :trs_counter)

ghs_timer(p::BlockOptProfile) = getfield(p, :ghs_timer)

ghs_counter(p::BlockOptProfile) = getfield(p, :ghs_counter)


Base.getproperty(p::BlockOptProfile, s::Symbol) = @restrict BlockOptProfile

Base.propertynames(p::BlockOptProfile) = ()


"""
Weaver

Interfaces with Weave.jl package, to construct `.html`
report containing iteration trace plots. 
"""
struct Weaver
    # arguments used in *.jmd files to weave report
    f_vals::Vector
    ∇f_norms::Vector
    Δ_vals::Vector
    p_norms::Vector
    ρ_vals::Vector
    weave_level::WeaveLevel

    # weave stuff
    function Weaver(weave_level::WeaveLevel = ALL)
        return new(
            Vector{Float64}(),
            Vector{Float64}(),
            Vector{Float64}(),
            Vector{Float64}(),
            Vector{Float64}(),
            weave_level,
        )
    end
end


f_vals(w::Weaver) = getfield(w, :f_vals)

∇f_norms(w::Weaver) = getfield(w, :∇f_norms)

Δ_vals(w::Weaver) = getfield(w, :Δ_vals)

p_norms(w::Weaver) = getfield(w, :p_norms)

ρ_vals(w::Weaver) = getfield(w, :ρ_vals)

weave!(w::Weaver, field::Symbol, val::Float64) = append!(getfield(w, field), val)

weave!(w::Weaver, accessor::Function, val::Float64) = append!(accessor(w), val)

weave_level(w::Weaver) = getfield(w, :weave_level)


Base.getproperty(w::Weaver, s::Symbol) = @restrict Weaver

Base.propertynames(w::Weaver) = ()


"""
    BlockOptTrace

Composite type responsible for logging, generating Weave 
reports, and storing a Profile of the simulation.
"""
struct BlockOptTrace
    model::Model
    driver::Driver
    profile::BlockOptProfile
    weaver::Weaver
    log_level::LogLevel
    io::IO

    function BlockOptTrace(model, driver)
        new(
            model,
            driver,
            BlockOptProfile(),
            Weaver(weave_level(driver)),
            log_level(driver),
            open(joinpath(directory(model), "trace.log"), "w+"),
        )
    end
end


# Forwarded Model Methods
model(t::BlockOptTrace) = getfield(t, :model)

directory(t::BlockOptTrace) = directory(model(t))


# Forwarded Driver Methods
driver(t::BlockOptTrace) = getfield(t, :driver)


# Forwarded Profile Methods 
profile(t::BlockOptTrace) = getfield(t, :profile)

trs_timer(t::BlockOptTrace) = trs_timer(profile(t))

trs_counter(t::BlockOptTrace) = trs_counter(profile(t))

ghs_timer(t::BlockOptTrace) = ghs_timer(profile(t))

ghs_counter(t::BlockOptTrace) = ghs_counter(profile(t))


# Forwarded Weaver Methods
weaver(t::BlockOptTrace) = getfield(t, :weaver)

weave!(t::BlockOptTrace, field, val) = weave!(weaver(t), field, val)

f_vals(t::BlockOptTrace) = f_vals(weaver(t))

∇f_norms(t::BlockOptTrace) = ∇f_norms(weaver(t))

Δ_vals(t::BlockOptTrace) = Δ_vals(weaver(t))

p_norms(t::BlockOptTrace) = p_norms(weaver(t))

ρ_vals(t::BlockOptTrace) = ρ_vals(weaver(t))

weave_level(t::BlockOptTrace) = weave_level(weaver(t))

log_level(t::BlockOptTrace) = getfield(t, :log_level)

io(t::BlockOptTrace) = getfield(t, :io)


Base.getproperty(t::BlockOptTrace, s::Symbol) = @restrict BlockOptTrace

Base.propertynames(t::BlockOptTrace) = ()


# generates logging methods info!, warn!, debug!, error!
for level in (:info, :debug, :warn, :error)
    lower_level_str = String(level)
    upper_level_str = uppercase(lower_level_str)
    upper_level_sym = Symbol(upper_level_str)
    fn = Symbol(lower_level_str * "!")
    label = " [" * upper_level_str * "] "
    @eval function $fn(trace::BlockOptTrace, args...)
        if log_level(trace) <= $upper_level_sym
            let io = io(trace)
                println(io, trunc(now(), Second), $label)
                for (idx, arg) in enumerate(args)
                    idx > 0 && show(io, arg)
                    println(io)
                end
                println(io, "")
                flush(io)
            end
        end
    end
end
