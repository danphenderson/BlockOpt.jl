import .Abstract: AbstractTrace, filename, level, io

@enum TraceLevel INFO DEBUG WARN ERROR WEAVE

"""
    Trace <: AbstractTrace

    Holds a record of a model throughout it's life. 
"""
Base.@kwdef struct Trace <: AbstractTrace
    level::TraceLevel = INFO
    filename::String = "Trace"
    io = open(filename, "w+")

    function Trace(level::TraceLevel, filename::String, io::IOStream)
        new(level, filename, io)
    end
end

Base.getproperty(t::Trace) = @restrict typeof(m)


Base.propertynames(t::Trace) = ()


filename(t::Trace) = getfield(t, :filename)


level(t::Trace) = getfield(t :level)


io(t::Trace) = getfield(t, :io)


for level in (:info, :debug, :warn, :error, :weave)
    lower_level_str = String(level)
    upper_level_str = uppercase(lower_level_str)
    upper_level_sym = Symbol(upper_level_str)
    fn = Symbol(lower_level_str)
    label = " [" * upper_level_str * "] "
    @eval function $fn(trace::Trace, args...)
        if level(trace) <= $upper_level_sym
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

function main()

end