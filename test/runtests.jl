using Test, Statistics, LinearAlgebra, Parameters # Test deps


# import Util Types
import BlockOpt: @lencheck, DimensionError, @contract, ContractError, @restrict, AccessError


# BlockOpt Types
import BlockOpt:
    BlockOptBackend,
    Model,
    Driver,
    DriverOptions,
    Weaver,
    EvaluationCounter,
    EvaluationTimer,
    BlockOptProfile,
    BlockOptTrace,
    Simulation


# Model imports
import BlockOpt:
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


# DriverOptions imports
import BlockOpt:
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


# Driver imports
import BlockOpt:
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


# Timer imports
import BlockOpt: Δt, on!, off!


# Counter imports
import BlockOpt: evaluations, increment!


# Profile imports
import BlockOpt: profile, trs_timer, trs_counter, ghs_timer, ghs_counter


# Weaver imports 
import BlockOpt: weaver, weave!, f_vals, ∇f_norms, Δ_vals, p_norms, ρ_vals


# BlockOptTrace imports 
import BlockOpt:
    model, driver, profile, log_level, directory, io, info!, debug!, warn!, error!


# Backend imports
import BlockOpt:
    fₖ,
    ∇fₖ_norm,
    pₖ_norm,
    Δₖ,
    ρ,
    model,
    driver,
    terminal,
    secantQN,
    blockQN,
    update_Sₖ,
    build_trs,
    solve_trs,
    build_trial,
    update_Δₖ,
    accept_trial,
    gAD,
    gHS,
    initialize


# Simulation imports
import BlockOpt: trace, backend, optimize!, optimize


# Recipes imports
import BlockOpt:
    rhotrace,
    rhotrace!,
    steptrace,
    steptrace!,
    radiustrace,
    radiustrace!,
    objtrace,
    objtrace!,
    gradtrace,
    gradtrace!


include("setup.jl")


@testset verbose = true "Utilities (See File: test/src/util.jl)  " begin

    include("src/util.jl")
end


@testset verbose = true "Model (See File: test/src/model.jl)     " begin

    include("src/model.jl")
end


@testset verbose = true "Options (See File: test/src/options.jl) " begin

    include("src/options.jl")
end


@testset verbose = true "Driver (See File: test/src/driver.jl)   " begin

    include("src/driver.jl")
end


@testset verbose = true "Library (See Directory: test/src/lib/)  " begin

    include("src/lib/trace.jl")

    include("src/lib/backend.jl")

    include("src/lib/simulation.jl")

    include("src/lib/recipes.jl")
end
