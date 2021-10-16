import .Abstract: AbstractDriver
import .Abstract: QN_update, S_update, options


"""
    Driver <: AbstractDriver  
"""
struct Driver <: AbstractDriver
    QN_update::Symbol
    S_update::Symbol
    options::AbstractDriverOptions

    function Driver(; QN_update, S_update, options)
        new(QN_update, S_update, options)
    end
end

Base.getproperty(d::Driver) = @restrict typeof(d)


Base.propertynames(d::Driver) = ()


QN_update(d::Driver) = getfield(d, :QN_update)


S_update(d::Driver) = getfield(d, :S_update)


options(d::Driver) = getfield(d, :options)