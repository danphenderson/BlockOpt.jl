using Test, LinearAlgebra, ForwardDiff

import Statistics: mean

# import Util Types
import BlockOpt:  @lencheck, DimensionError,  @contract, ContractError,  @restrict, AccessError


 # BlockOpt Types
import BlockOpt: BlockOptBackend, Model, Driver, DriverOptions, Weaver, EvaluationCounter,
    EvaluationCounter, BlockOptProfile, BlockOptTrace 


# Model imports
import BlockOpt: name, obj, grad!, grad, objective, gradient, initial_iterate, formula,
    dimension, directory, objective!, gradient!, initial_iterate!, formula!, final,
    hess_sample, hessAD


# DriverOptions imports
import BlockOpt: samples, Δ_max, δ_tol, ϵ_tol, max_iterations, weave_level, log_level,
    samples!, Δ_max!, δ_tol!, ϵ_tol!, max_iterations!, weave_level!, log_level!,
    LogLevel, INFO, DEBUG, WARN, ERROR, WeaveLevel, NONE, ALL


# Driver imports
import BlockOpt: orth, pflag, QN_update, SR1, PSB, S_update, A, B, C, D, E, F


# Timer imports
import BlockOpt: EvaluationTimer, Δt, on!, off!


# Counter imports
import BlockOpt: current_count, increment!


# Profile imports
import BlockOpt: profile, trs_timer, trs_counter, ghs_timer, ghs_counter


# Weaver imports 
import BlockOpt: weaver, weave!


# BlockOptTrace imports 
import BlockOpt: model, driver, profile, log_level, directory, io, 
    info!, debug!, warn!, error!


# Backend imports
import BlockOpt: fₖ, ∇fₖ_norm, pₖ_norm, Δₖ, ρ, model, driver, terminal, secantQN,
    blockQN, update_Sₖ, build_trs, solve_trs, build_trial, update_Δₖ, accept_trial,
    gAD, gHS, initialize


# Simulation imports
import BlockOpt: trace, backend, optimize!, optimize 


@testset "Utilities (see test/util.jl)         " begin 
    include("util.jl")
end


@testset "Preliminary (see test/lib.jl)        " begin
    include("types.jl")
end


@testset "Simple Iteration (see test/solver.jl)" begin
   include("solver.jl")
end

# function rosenbrock_model(n::Int) 
#     rosen_model = Model("rosenbrock")

#     objective!(rosen_model, 
#         x -> begin
#             N = lastindex(x)
#             return 100sum((x[i+1] - x[i]^2)^2 for i = 1:N-1) + sum((x[i] - 1)^2 for i = 1:N-1)
#         end
#     )

#     gradient!(rosen_model, 
#         (g, x) -> begin
#             N = lastindex(x)
#             g[1] = -2*(1 - x[1]) - 400*x[1]*(-x[1]^2 + x[2])
#             for i in 2:N-1
#                 g[i] = -2*(1 - x[i]) + 200*(-x[i-1]^2 + x[i]) - 400*x[i]*(-x[i]^2 + x[1 + i])
#             end
#             g[N] = 200 * (x[N] - x[N-1]^2)
#             return g
#         end
#     )

#     initial_iterate!(rosen_model, randn(100))

#     return rosen_model
# end


# @testset "  S Updates" begin
#     n, w = 100, 20
#     S = randn(n, w)
#     Y = randn(n, w)
#     p = randn(n)

#     # testing orthooganlity of output...add more
#     S_new = a(S, Y, p); @test S_new'*S_new ≈ I
#     S_new = b(S, Y, p); @test S_new'*S_new ≈ I
#     S_new = c(S, Y, p); @test S_new'*S_new ≈ I
#     # CRUCIAL ISSUE Y orth to S_new 
#     # LOOK AT NORMALIZATION

#     S_new = d(S, Y, p); @test S_new'*S_new ≈ I
#     S_new = e(S, Y, p); @test S_new'*S_new ≈ I
#     S_new = f(S, Y, p); @test S_new'*S_new ≈ I
# end





# @testset "  QN Updates" begin
#     n, w, δ = 100, 20, 1.0e-12
#     f, ∇f, ∇²f, min = convex_quadratic_program(n)

#     U = orth(randn(n, w))
#     V = ∇²f*U
#     x = randn(n)
#     y =  ∇²f*x
#     H = zeros(n, n) + I

#     # requitements testing
#     @test U'V ≈ V'U 
#     @test H' ≈ H

#     # secant equation
#     Hnew = SR1(H, U, V, δ); @test Hnew*V ≈ U 
#     Hnew = PSB(H, U, V, δ); @test Hnew*V ≈ U
#     Hnew = SR1(H, x, y, δ); @test Hnew*y ≈ x 
#     Hnew = PSB(H, x, y, δ); @test Hnew*y ≈ x 
# end