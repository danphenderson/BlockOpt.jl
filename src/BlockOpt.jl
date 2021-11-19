module BlockOpt

import Base: copy


import LinearAlgebra:
    diagm, BLAS, Symmetric, mul!, norm, dot, issymmetric, rank, qr, I, pinv, eigvals


import Statistics: mean


import ForwardDiff: ForwardDiff, Dual, jacobian


import TRS: trs_small, trs


import Weave


import RecipesBase: RecipesBase, @series, @recipe, @userplot


import Printf: @sprintf, @printf


import Dates: Date, Second, now, Minute


export optimize


# Types
export Model, Driver


# See model.jl
export model,
    name,
    obj,
    grad!,
    grad,
    objective,
    gradient,
    initial_iterate,
    formula,
    dimension,
    directory,
    objective!,
    gradient!,
    initial_iterate!,
    formula!,
    final,
    hess_sample,
    hessAD


# See options.jl
export DriverOptions,
    samples,
    Δ_max,
    δ_tol,
    ϵ_tol,
    max_iterations,
    weave_level,
    log_level,
    samples!,
    Δ_max!,
    δ_tol!,
    ϵ_tol!,
    max_iterations!,
    weave_level!,
    log_level!,
    LogLevel,
    INFO,
    DEBUG,
    WARN,
    ERROR,
    WeaveLevel,
    NONE,
    ALL


# See driver.jl
export driver,
    orth,
    pflag,
    QN_update,
    SR1,
    PSB,
    S_update,
    S_update_a,
    S_update_b,
    S_update_c,
    S_update_d,
    S_update_e,
    S_update_f


# See trace.jl
export trace,
    Δt,
    evaluations,
    trs_timer,
    trs_counter,
    ghs_timer,
    ghs_counter,
    f_vals,
    ∇f_norms,
    Δ_vals,
    p_norms,
    ρ_vals


# See recipes.jl
export rhotrace,
    rhotrace!,
    steptrace,
    steptrace!,
    radiustrace,
    radiustrace!,
    objtrace,
    objtrace!,
    gradtrace,
    gradtrace!


# See simulation.jl
export weave


include("util.jl")


include("model.jl")


include("options.jl")


include("driver.jl")


include("lib/trace.jl")


include("lib/backend.jl")


include("simulation.jl")


"""
    optimize(model::Model, driver::Driver)


An entry-point into the minimization iteration with the given `model` subject to the specified `driver`.
"""
optimize(model::Model, driver::Driver) = optimize!(Simulation(model, driver))


"""
    optimize(model::Model, driver::Driver)


Attempts to determine the unconstrained minimum of `f` via a first-order method with the initial iterate
given by `x₀`. The gradient ∇f! must be specified as an inplace operation.
"""
optimize(f::Function, ∇f!::Function, x₀::AbstractArray) = optimize(
    Model("Missing"; objective = f, gradient = ∇f!, initial_iterate = x₀),
    Driver(),
)


include("lib/show.jl")


include("lib/recipes.jl")


end # module
