
"""
Timer

Holds a count that is incremented in units of 1. 
"""
mutable struct EvaluationTimer
    Δt
    
    function EvaluationTimer() new(0.0) end
end

Δt(t::EvaluationTimer) = getfield(t, :Δt)

on!(t::EvaluationTimer) = setfield!(t, :Δt,  Δt(t) - time())

off!(t::EvaluationTimer) = setfield!(t, :Δt, time() + Δt(t))
 
Base.getproperty(t::EvaluationTimer, s::Symbol) = @restrict EvaluationTimer

Base.propertynames(t::EvaluationTimer) = ()


"""
Countera

Holds a count that is incremented in units of 1. 
"""
mutable struct EvaluationCounter
    current_count::Int

    function EvaluationCounter() new(0) end
end

current_count(c::EvaluationCounter) = getfield(c, :current_count)

increment!(c::EvaluationCounter, units=1) = begin
    units > 0 && setfield!(c, :current_count, current_count(c) + units)
    return current_count(c)
end

Base.getproperty(t::EvaluationCounter, s::Symbol) = @restrict EvaluationCounter

Base.propertynames(t::EvaluationCounter) = ()


"""
Profile

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

function Base.show(io::IO, p::BlockOptProfile)
    println(io, "  Profile:")
    println(io, "  ------------------------------------")
    print(io,   "      trs_counter:      $(trs_counter(p))")
    println(io, "      trs_timer:        $(trs_timer(p))")
    print(io,   "      ghs_counter:      $(ghs_counter(p))")
    println(io, "      ghs_timer:        $(ghs_timer(p))")
    flush(io)
    return nothing
end


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
    function Weaver(weave_level::WeaveLevel=ALL)
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


weave!(w::Weaver, field, val) = append!(getfield(w, field), val)

weave!(w::Nothing, field, val) = getfield(w, field)

weave_level(w::Weaver) = getfield(w, :weave_level)

function Base.show(io::IO, w::Weaver)
    for field ∈ fieldnames(Weaver)
        display(getfield(w, field))
    end
    flush(io)
    return nothing
end


"""
BlockOptTrace

Composite type responsible for logging, generating Weave 
reports, and storing a Profile of a simulation.
"""
struct BlockOptTrace
    model::Model
    driver::Driver
    profile::BlockOptProfile
    weaver::Weaver
    log_level::LogLevel
    directory::String
    io::IO

    function BlockOptTrace(model, driver)
        new(model,
            driver,
            BlockOptProfile(),
            Weaver(weave_level(driver)),
            log_level(driver),
            directory(model),
            open(joinpath(directory(model), "trace.log"), "w+"),  
        )
    end
end


model(t::BlockOptTrace) = getfield(t, :model)

directory(t::BlockOptTrace) = directory(model(t))

driver(t::BlockOptTrace) = getfield(t, :driver)

log_level(t::BlockOptTrace) = getfield(t, :log_level)

profile(t::BlockOptTrace) = getfield(t, :profile)

trs_timer(t::BlockOptTrace) = trs_timer(profile(t))

trs_counter(t::BlockOptTrace) = trs_counter(profile(t))

ghs_timer(t::BlockOptTrace) = ghs_timer(profile(t))

ghs_counter(t::BlockOptTrace) = ghs_counter(profile(t))

weaver(t::BlockOptTrace) = getfield(t, :weaver)

weave!(t::BlockOptTrace, field, val) = weave!(weaver(t), field, val)

weave_level(t::BlockOptTrace) = weave_level(weaver(t))

io(t::BlockOptTrace) = getfield(t, :io)

Base.getproperty(t::BlockOptTrace, s::Symbol) = @restrict BlockOptTrace

Base.propertynames(t::BlockOptTrace) = ()

function Base.show(io::IO, t::BlockOptTrace)
    println(io, "Trace:")
    println(io, "----------------------------------------")
    show(profile(t))
    show(weaver(t))
    return nothing
end


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
                print(io, trunc(now(), Dates.Second), $label)
                for (idx, arg) in enumerate(args)
                    idx > 0 && show(io, arg)
                end
                println(io)
                flush(io)
            end
        end
    end
end
