```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
    using BlockOpt
    using LinearAlgebra
end
```

# Model Interface
```@docs
Model
objective!
gradient!
initial_iterate!
formula!
objective
gradient
dimension
formula
record
```

# Constructing a Model

Calling `Model{T, S}()` creates an empty model instance with storage type
`S <: AbstractArray` and element type `T <: Real`.
This example illustrates creating an empty model that operates on a densely stored array with `Float64` element type.

```repl
julia> m = Model{Float64, Array}() 
Model: 
----------------------------------------
   objective:        missing
   gradient:         missing
   initial iterate:  missing
   dimension:        missing
```

We assign model `m` the two dimensional [rosenbrock](https://en.wikipedia.org/wiki/Rosenbrock_function) as it's objective function, i.e.  


``f(x) = 100(x₂ - x₁²)² + (1 - x₁)²``.  


```repl
julia> f(x) = 100(x[2] - x[1]^2)^2 + (1 - x[1])^2;
julia> objective!(m, f)
Model: 
----------------------------------------
   objective:        f
   gradient:         missing
   initial iterate:  missing
   dimension:        missing
```

Now, we should give model `m` a sensible name.

```repl
julia> name!(m, "2D-Rosenbrock")
Model: 2D-Rosenbrock
----------------------------------------
   objective:        f
   gradient:         missing
   initial iterate:  missing
   dimension:        missing
```

Next, we specify the gradient function to model `m` as an in-place
computation.

```repl
julia> ∇f!(g, x) = (g .= [-400(x[2] - x[1]^2)x[1] - 2(2-x[1]), 200(x[2]-x[1]^2)]);
julia> gradient!(m, ∇f!)
Model: 2D-Rosenbrock
----------------------------------------
   objective:        f
   gradient:         ∇f!
   initial iterate:  missing
   dimension:        missing
```

Here, the direction of steepest descent is stored _in the place_  of the passed in parameter g.


Next, we set the initial iterate of `m` which also assigns a cooresponding dimension to model `m`.

```repl
julia> initial_iterate!(m, [-1.0, -1.2])
Model: 2D-Rosenbrock
----------------------------------------
   objective:        f
   gradient:         ∇f!
   initial iterate:  [-1.0, -1.2]
   dimension:        2
   formula:          missing
```

Finally, we specify the optional `formula` of model `m`. 

```repl
julia> formula!(m, "f(x) = 100(x₂ - x₁²)² + (1 - x₁)²")
Model: 2D-Rosenbrock
f(x) = 100(x₂ - x₁²)² + (1 - x₁)²
----------------------------------------
    objective:        f
    gradient:         ∇f!
    initial iterate:  [-1.0, -1.2]
    dimension:        2
```