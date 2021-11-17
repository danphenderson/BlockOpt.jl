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
The methods below are simple fallbacks of the forwarded `Driver` methods.

!!! note 
    It is possible to pass a `DriverOptions` instance as the `options` keyword argument
    to a `Driver` constructor.

```@docs
samples(o::DriverOptions)
Δ_max(o::DriverOptions)
δ_tol(o::DriverOptions)
ϵ_tol(o::DriverOptions)
max_iterations(o::DriverOptions)
weave_level(o::DriverOptions)
log_level(o::DriverOptions)
samples!
Δ_max!
δ_tol!
ϵ_tol!
max_iterations!
weave_level!
log_level!
```