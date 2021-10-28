"""
EvaluationCounter

Holds a count of the trust region subproblem solves and gHS evaluations.
"""
mutable struct EvaluationCounter
    trs_solve::Int
    ghs_eval::Int
    function EvaluationCounter()
        new(0, 0)
    end
end


"""
increment!

Increment field `s` of trace `t` by one.
"""
increment!(c::EvaluationCounter, s::Symbol) = setfield!(t, s, getfield(c, s) + 1)


Base.getproperty(c::EvaluationCounter) = @restrict typeof(c)


Base.propertynames(c::EvaluationCounter) = ()


function Base.show(io::IO, c::EvaluationCounter)
    println(io, "----------------------------------------")
    println(io, "    gradHS evals:     $(ghs_evals(c))")
    println(io, "    trs solves `k`:   $(trs_solves(c))")
    flush(io)
    return nothing
end


"""
Weaver

Interfaces with Weave.jl
"""
struct Weaver
    # arguments used in *.jmd files to weave report
    f_vals::Vector
    ∇f_norms::Vector
    p_norms::Vector
    Δ_vals::Vector
    ρ_vals::Vector

    # weave stuff
    function Weaver(directory)
        return new(Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}(), Vector{Float64}())
    end
end


Base.getproperty(w::Weaver) = @restrict typeof(w)


Base.propertynames(w::Weaver) = ()


"""
weave!

Add an iteration observation to the weaver. 
"""
weave!(w::Weaver, field, val) = append!(getfield(w, field), val)


weave!(w::Nothing, field, val) = nothing


"""

    Trace

    Thinks Longer and a weaver
"""
struct BlockOptTrace <: AbstractBackend
    io::IO
    level::LogLevel
    counter::EvaluationCounter
    weaver::Union{Nothing, Weaver}
    function BlockOptTrace(m::Model, d::Driver)
        i = 1
        while !isdirpath(joinpath(directory(m), "Trace$i")); i+=1; end
        dir = mkdir(joinpath(directory(record), "Trace$i"))
        new(
            open(joinpath(dir, "logs.txt"), "w+"), 
            log_level(d),
            EvaluationCounter(),
            weave_level(d) == WEAVE ? Weaver(dir) : nothing,
        )
    end
end


Base.getproperty(t::BlockOptTrace) = @restrict typeof(t)


Base.propertynames(t::BlockOptTrace) = ()


counter(t::BlockOptTrace) = getfield(t, :counter)


increment!(t::BlockOptTrace) = increment!(counter(t))


weaver(t::BlockOptTrace) = getfield(t, :weaver)


weave!(t::BlockOptTrace, field, val) = weave!(weaver(t), field, val)


io(t::BlockOptTrace) = getfield(t, :io)


level(t::BlockOptTrace) = getfield(t, :log_level)


for l in (:info!, :debug!, :warn!, :error!)
    upper_str = uppercase(String(l))
    upper_sym = Symbol(upper_str)
    label = " [" * upper_str * "] "
    @eval macro $l(trace::BlockOptTrace, args...)
        if level(trace) <= $upper_sym
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
