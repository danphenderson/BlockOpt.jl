```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
import BlockOpt: model, name, obj, grad!, grad, objective, gradient, initial_iterate, formula,
    dimension, directory, objective!, gradient!, initial_iterate!, formula!,
    hess_sample, hessAD
end
```

# Model Interface
```@docs
name
objective
gradient
initial_iterate
formula
dimension
directory
objective!****
gradient!
initial_iterate!
formula!
obj
grad!
hessAD
hess_sample
```

