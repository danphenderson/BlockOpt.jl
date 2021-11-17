```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
import BlockOpt: Model, name, obj, grad!, grad, objective, gradient, initial_iterate, formula,
    dimension, directory, objective!, gradient!, initial_iterate!, formula!,
    hess_sample, hessAD
end
```

# Model

```@docs
Model
```

## Interface

```@docs
name
objective
gradient
initial_iterate
formula
dimension
directory
objective!
gradient!
initial_iterate!
formula!
obj
grad!
hessAD
hess_sample
```

