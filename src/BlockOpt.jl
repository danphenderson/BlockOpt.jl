module BlockOpt


import LinearAlgebra: diagm, BLAS, Symmetric, mul!, norm, dot, issymmetric, rank, qr, I, pinv, eigvals

import Statistics: mean

import ForwardDiff: Dual, jacobian

import TRS: trs_small

import RecipesBase: RecipesBase, @series, @recipe, @userplot

import Printf: @sprintf, @printf

import Dates: Second, now

# Types
export Model, Driver


# See model.jl
export model, name, obj, grad!, grad, objective, gradient, initial_iterate, formula,
    dimension, directory, objective!, gradient!, initial_iterate!, formula!, final,
    hess_sample, hessAD

# See options.jl
export samples, Δ_max, δ_tol, ϵ_tol, max_iterations, weave_level, log_level,
    samples!, Δ_max!, δ_tol!, ϵ_tol!, max_iterations!, weave_level!, log_level!,
    LogLevel, INFO, DEBUG, WARN, ERROR, WeaveLevel, NONE, ALL

# See driver.jl
export driver, orth, pflag, QN_update, SR1, PSB, S_update, A, B, C, D, E, F

# See trace.jl
export Δt, evaluations, trs_timer, trs_counter, ghs_timer, ghs_counter, f_vals, 
    ∇f_norms, Δ_vals, p_norms, ρ_vals

# See simulation.jl
export optimize

# See recipes.jl
export rhotrace, rhotrace!, steptrace, steptrace!, radiustrace, radiustrace!, objtrace, objtrace!, gradtrace, gradtrace!


include("util.jl")

include("model.jl")

include("options.jl")

include("driver.jl")

include("lib/trace.jl")

include("lib/backend.jl")

include("lib/simulation.jl")

include("lib/show.jl")

include("lib/recipes.jl")


end # module