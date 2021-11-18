```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
import BlockOpt: DriverOptions, samples, Δ_max, δ_tol, ϵ_tol, max_iterations, weave_level, log_level,
    samples!, Δ_max!, δ_tol!, ϵ_tol!, max_iterations!, weave_level!, log_level!
end
```

# Options

```@docs
DriverOptions
```

## Interface

The `DriverOptrions` type is best thought of as the mutable protion of a `Driver` instance.
The methods below are forwarded to the `Driver`, which has a `DriverOptions` instance. 

!!! note 
    It is possible to pass a `DriverOptions` instance as the `options` keyword argument
    to the `Driver` constructor.

    This is useful when constructing mutiple drivers with the same set of options. 

```@docs
samples(o::DriverOptions)
Δ_max(o::DriverOptions)
δ_tol(o::DriverOptions)
ϵ_tol(o::DriverOptions)
max_iterations(o::DriverOptions)
samples!
Δ_max!
δ_tol!
ϵ_tol!
max_iterations!
weave_level!
log_level!
```