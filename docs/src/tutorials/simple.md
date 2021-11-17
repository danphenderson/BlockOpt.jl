```@meta
CurrentModule = BlockOpt
DocTestSetup = quote
    using BlockOpt
    using LinearAlgebra
end
```

# Simple Use Case
We consider finding an unconstrained minimum of the [generalized rosenbrock](https://en.wikipedia.org/wiki/Rosenbrock_function) where the objective function is


```math
f(x) = \sum_{i=1}^{N-1} \left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\right].
```

Translating the objective function into julia code below.

```julia-repl
julia> function rosen(x)
           N = lastindex(x)
           100sum((x[i+1] - x[i]^2)^2 for i = 1:N-1) + sum((x[i] - 1)^2 for i = 1:N-1)
       end
```

The simulation terminatates when the first-order neccessary condition for the generalized
rosenbrock's gradient ``∇f`` is satisfied, i.e.

```math
|| \nabla f(x) || \leq \epsilon.
```

Differentiating the objective function and translating to julia code.

```julia-repl
julia> function ∇rosen!(g, x)
           N = lastindex(x)
           g[1] = -2*(1 - x[1]) - 400*x[1]*(-x[1]^2 + x[2])

           for i in 2:N-1
               g[i] = -2*(1 - x[i]) + 200*(-x[i-1]^2 + x[i]) - 400*x[i]*(-x[i]^2 + x[1 + i])
           end
           
           g[N] = 200 * (x[N] - x[N-1]^2)    
           return g
       end
∇rosen! (generic function with 1 method)
```

Consider dimension ``n=100`` and randomly select `x₀` from the
the ``100``-dimensional hypercube.

```julia-repl
julia> x₀ = randn(100);
```

Then our call to `optimize` is the entry-point of the unconstrained minimization interation. 

```julia-repl
julia> optimize(rosen, ∇rosen!, x₀)
SUCCESS 8.070336658758971e-7 ≤ 1.0e-5 in 528 steps
--------------------------------------
  Minimum f:      5.311172726630893e-16
  Minimum ||∇f||: 8.070336658758971e-7
  Minimum Δ:      0.005844719845773086
  Minimum Step:   6.030122388810338e-8

  Model: 
  -------------------
    objective:         rosen
    gradient:          ∇rosen!
    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]
    dimension:         100
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Missing
    objective formula: missing
  Driver:
  -------------------
    S_update:  S_update_c
    QN_update: SR1
    pflag:     false
    Options:
      samples:        6
      Δ_max:          100.0
      δ_tol:          1.0e-12
      ϵ_tol:          1.0e-5
      max_iterations: 2000
  Trace:
  -------------------
    Weaver:
      f_vals:   [37156.548946, ..., 0.000000, 0.000000, 0.000000]
      ∇f_norms: [15116.003941, ..., 0.000293, 0.000016, 0.000001]
      Δ_vals:   [5.984993, ..., 0.187031, 0.187031, 0.187031]
      p_norms:  [5.172082, ..., 0.000045, 0.000002, 0.000000]
      ρ_vals:   [0.931152, ..., 0.985198, 0.983784, 0.986492]
    Profile:
      trs_counter: 528
      trs_timer:   0.07330679893493652
      ghs_counter: 430
      ghs_timer:   0.07087516784667969
```

Here, the output is showing a `Simulation` instance in it's terminal state, which
happens to be a success!


## Constructing a Model

We extend our simple use case to define a model, which creates a directory to keep track
of simulations throughout the model's life.

```julia-repl
julia> m = Model("Rosenbrock")
  Model: 
  -------------------
    objective:         missing
    gradient:          missing
    initial iterate:   missing
    dimension:         missing
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock
    objective formula: missing
```

Above is an empty model which is incrementally loaded.

```julia-repl
julia> objective!(m, rosen)
rosen (generic function with 1 method)

julia> gradient!(m, ∇rosen!)
∇rosen! (generic function with 1 method)

julia> initial_iterate!(m, x₀); m
  Model: 
  -------------------
    objective:         rosen
    gradient:          ∇rosen!
    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]
    dimension:         100
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock
    objective formula: missing
```

The model is now loaded to a `final` state, meaning that the objective and gradient function
can no longer be modified. 


We may optionally choose to specify a formula repsenting the objective of `m`.

```julia-repl
julia> rosen_formula = "\$\\sum_{i=1}^{N-1} \\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\right]\$";

julia> formula!(m, rosen_formula)
"\$\\sum_{i=1}^{N-1} \\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\right]\$"

julia> m
  Model: 
  -------------------
    objective:         rosen
    gradient:          ∇rosen!
    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]
    dimension:         100
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock
    objective formula: $\sum_{i=1}^{N-1} \left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\right]$
```

Our model `m` is now fully constructed. One thing to note is the directory above, 
which was created when declaring the model `m`. The `Model`'s constructor creates a directory
relative to the user's current working directory (as determined by a `pwd()` call). The relative portion
to the user's working enviroment is created from the models name, in our case `\Rosenbrock`.


## Constructing a Driver
The goal of creating a model is to record simulation information over multiples trials,
where each trial incorporates the second-order hessian information into each step's QN
update in a unique manner. This is done through construction of a driver.

```julia-repl
julia> default = Driver() # default parameters and options
  Driver:
  -------------------
    S_update:  S_update_c
    QN_update: SR1
    pflag:     false
    Options:
      samples:        6
      Δ_max:          100.0
      δ_tol:          1.0e-12
      ϵ_tol:          1.0e-5
      max_iterations: 2000
```

The `default` driver is what was used in the simple use case above.
We can alternatively specify keyward arguments to the constructor.

```julia-repl
julia> psb_default = Driver(QN_update = PSB)
  Driver:
  -------------------
    S_update:  S_update_c
    QN_update: PSB
    pflag:     false
    Options:
      samples:        6
      Δ_max:          100.0
      δ_tol:          1.0e-12
      ϵ_tol:          1.0e-5
      max_iterations: 2000
```

See `pflag` and `S_update` for information on the other keyword arguments.


## Configurations

By dispatching optimize on a user-defined model and driver, it allows us to make
meaningfull comparisions between different parameters.

```julia-repl
julia> optimize(m, psb_default)
FAIL 3.3237010117680144 ≰ 1.0e-5 in 2000 steps
--------------------------------------
  Minimum f:      27.704563096307897
  Minimum ||∇f||: 2.55525408127963
  Minimum Δ:      0.005317424470907392
  Minimum Step:   0.005317424470907389

  Model: 
  -------------------
    objective:         rosen
    gradient:          ∇rosen!
    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]
    dimension:         100
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock
    objective formula: $\sum_{i=1}^{N-1} \left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\right]$
  Driver:
  -------------------
    S_update:  S_update_c
    QN_update: PSB
    pflag:     false
    Options:
      samples:        6
      Δ_max:          100.0
      δ_tol:          1.0e-12
      ϵ_tol:          1.0e-5
      max_iterations: 2000
  Trace:
  -------------------
    Weaver:
      f_vals:   [37156.548946, ..., 27.774588, 27.740267, 27.704563]
      ∇f_norms: [15116.003941, ..., 3.329326, 3.680141, 3.323701]
      Δ_vals:   [5.445043, ..., 0.021270, 0.021270, 0.021270]
      p_norms:  [4.350945, ..., 0.014781, 0.014780, 0.014779]
      ρ_vals:   [1.117260, ..., 1.675970, 1.665151, 1.676431]
    Profile:
      trs_counter: 2000
      trs_timer:   0.30657124519348145
      ghs_counter: 1969
      ghs_timer:   0.2530691623687744
```

Here, our simulation failed to reach a successfull terminal state with the `psb_driver` driver.
The next step is to configure the `max_iterations` of the `psb_driver` to larger value.

```julia-repl
julia> max_iterations!(psb_default, 10000)
10000

julia> optimize(m, psb_default)
SUCCESS 9.927950264884106e-6 ≤ 1.0e-5 in 5590 steps
--------------------------------------
  Minimum f:      5.511229138712141e-11
  Minimum ||∇f||: 9.927950264884106e-6
  Minimum Δ:      0.01131181544998996
  Minimum Step:   6.449591660831643e-8

  Model: 
  -------------------
    objective:         rosen
    gradient:          ∇rosen!
    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]
    dimension:         100
    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock
    objective formula: $\sum_{i=1}^{N-1} \left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\right]$
  Driver:
  -------------------
    S_update:  S_update_c
    QN_update: PSB
    pflag:     false
    Options:
      samples:        6
      Δ_max:          100.0
      δ_tol:          1.0e-12
      ϵ_tol:          1.0e-5
      max_iterations: 10000
  Trace:
  -------------------
    Weaver:
      f_vals:   [37156.548946, ..., 0.000000, 0.000000, 0.000000]
      ∇f_norms: [15116.003941, ..., 0.000010, 0.000012, 0.000010]
      Δ_vals:   [5.791650, ..., 0.045247, 0.045247, 0.045247]
      p_norms:  [4.512299, ..., 0.000000, 0.000000, 0.000000]
      ρ_vals:   [1.097135, ..., 1.760999, 1.752575, 1.761029]
    Profile:
      trs_counter: 5590
      trs_timer:   0.7602972984313965
      ghs_counter: 5575
      ghs_timer:   0.7890379428863525
```

Allowing for $1000$ iterations yeilds first-order neccessary convergence within
the specified tolerance, given by an `ϵ_tol(psb_default)` call. See the `Options` section
of the manual for more information on specifying simulation configurations. 

## Analyzing Simulation

Let us assign the variable `s_psb_default` and `s_default` to denote the simulations configured with 
the `psb_defualt` and `default` drivers.

```julia-repl
julia> s_psb_default = optimize(m, psb_defualt);
julia> s_default = optimize(m, default);
```

Now we compare the trace of `f_vals` over the iteration.

```julia-repl
julia> using Plots;     # to install: using Pkg; Pkg.add("Plots")
julia> objtrace(s_psb_defualt, s_defualt)
```

**TODO** Add photo

We proceed by adding gradients to the existing plot.

```julia-repl
julia> gradtrace!(s_psb_defualt, s_defualt)
```

**TODO** Add photo


See: `rhotrace`, `steptrace`, `radiustrace` and their corresponding `!` versions.