```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
import BlockOpt: Simulation, trs_timer, trs_counter, ghs_timer, ghs_counter, f_vals, ∇f_norms, p_norms,
    Δ_vals, ρ_vals, objtrace, gradtrace, radiustrace, steptrace, rhotrace
```

# Simulation

```@docs
Simulation
```

## Subroutines of `optimize!`

When calling `optimize(model, driver)` the fallback is `optimize!(s)` where
simulation `s` is internally constructed. The responsibility of `s` is to orchestrate
the iteration defined in it's `backend` and make observations to generate the `trace`.

The `backend` defines subroutines for `s`'s memory manipulations for each step in it's
iteration. Since then backend delegates it's behavior to `s`, we dispatch the backends subroutines
to `s` while adding additional execution steps to generate the simulations trace.



```@docs
initialize(s::Simulation)
terminal(s::Simulation)
build_trs(s::Simulation)
solve_trs(s::Simulation)
build_trial(s::Simulation)
accept_trial(s::Simulation)
secantQN(s::Simulation)
update_Sₖ(s::Simulation)
gHS(s::Simulation)
blockQN(s::Simulation)
```




## Interface

Methods dispatch on a terminal simulation returned from an `optimize` call.

```@docs
trs_timer(s::Simulation)
trs_counter(s::Simulation)
ghs_timer(s::Simulation)
ghs_counter(s::Simulation)
f_vals(s::Simulation)
∇f_norms(s::Simulation)
p_norms(s::Simulation)
Δ_vals(s::Simulation)
ρ_vals(s::Simulation)
```

## Recipes

To use the listed recipes you must have (`Plots.jl`)[http://docs.juliaplots.org/latest/]
in your current namespace, i.e. loaded from calling `using Plots`. This assumes the Plots
package has already been installed through `Pkg.jl`.

```@docs
objtrace
gradtrace
radiustrace
steptrace
rhotrace
```
