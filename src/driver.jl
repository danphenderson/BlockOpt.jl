export Driver


"""
    Driver <: AbstractDriver  
"""
struct Driver <: AbstractDriver
    QN_update::Symbol
    S_update::Symbol
    options::AbstractDriverOptions

    function Driver(QN_update=:blockSR1, S_update=:S_update_d)
        new(QN_update, S_update, DriverOptions())
    end
end


QN_update(d::Driver) = getfield(d, :QN_update)


S_update(d::Driver) = getfield(d, :S_update)


options(d::Driver) = getfield(d, :options)


Base.getproperty(d::Driver) = @restrict typeof(d)


Base.propertynames(d::Driver) = ()


function Base.show(io::IO, d::Driver)
    println(io, "Driver:")
    println(io, "----------------------------------------")
    println(io, "    QN update:        $(QN_update(d))")
    println(io, "    S  update:        $(S_update(d))")
    show(options(d))
    return nothing
end