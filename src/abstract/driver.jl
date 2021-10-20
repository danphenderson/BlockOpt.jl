export AbstractDriver
export QN_update, S_update, options
"""
    AbstractDriver <: AbstractBlockOptType

Defines the interfaced base type of an optimization model driver.

# Implements:
    Accesors:
        QN_update
        S_update
        options
    Inherts:
        AbstractDriverOptions
"""
abstract type AbstractDriver <: AbstractBlockOptType end


"""
    QN_update(d::AbstractDriver)
"""
QN_update(d::AbstractDriver) = @contract AbstractDriver :QN_update


"""
    S_update(d::AbstractDriver)
"""
S_update(d::AbstractDriver) = @contract AbstractDriver :S_update


"""
    options(d::AbstractDriver)

Returns a reference to a subtype of `AbstractDriverOptions`.
"""
options(d::AbstractDriver)::AbstractDriverOptions = @contract AbstractDriver :options


samples(d::AbstractDriver) = samples(options(d))


samples!(d::AbstractDriver, samples) =  samples!(options(d), samples)


Δ_max(d::AbstractDriver) = Δ_max(options(d))


Δ_max!(d::AbstractDriver, Δ_max) = Δ_max!(options(d), Δ_max)


δ_tol(d::AbstractDriver) = δ_tol(options(d))


δ_tol!(d::AbstractDriver, δ_tol) = δ_tol!(options(d), δ_tol)


ϵ_tol(d::AbstractDriver) = ϵ_tol(options(d))


ϵ_tol!(d::AbstractDriver, ϵ_tol) = ϵ_tol!(options(d), ϵ_tol)


max_iterations(d::AbstractDriver) =  max_iterations(options(d))


max_iterations!(d::AbstractDriver, m) = max_iterations!(options(d), m)