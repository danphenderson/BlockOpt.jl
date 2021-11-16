@testset "S Updates" begin
    S = orth(randn(n, 2w - 1))
    Y = randn(n, 2w - 1)
    p = randn(n)

    S_new = S_update_a(S, Y, p)

    @test S_new' * S_new ≈ I

    S_new = S_update_b(S, Y, p)

    @test S_new' * S_new ≈ I

    @test norm(S_new' * S) ≤ sqrt(eps(Float64)) # orthoganlity test

    S_new = S_update_c(S, Y, p)

    @test S_new' * S_new ≈ I

    @test norm(S_new' * S) ≤ sqrt(eps(Float64)) # orthoganlity test

    S_new = S_update_d(S, Y, p)

    @test S_new' * S_new ≈ I

    S_new = S_update_e(S, Y, p)

    @test S_new' * S_new ≈ I

    S_new = S_update_f(S, Y, p)

    @test S_new' * S_new ≈ I
end


@testset "QN Updates" begin
    U = orth(randn(n, 2w + 1))
    V = ∇²f * U
    x = randn(n)
    y = ∇²f * x
    H = zeros(n, n) + I

    @test U'V ≈ V'U

    @test H' ≈ H

    Hnew = SR1(H, U, V, δ)
    @test Hnew * V ≈ U

    Hnew = PSB(H, U, V, δ)
    @test Hnew * V ≈ U

    Hnew = SR1(H, x, y, δ)
    @test Hnew * y ≈ x

    Hnew = PSB(H, x, y, δ)
    @test Hnew * y ≈ x
end




@testset "testing constructor" begin

    @test S_update(test_driver) ≡ S_UPDATE

    @test QN_update(test_driver) ≡ QN_UPDATE

    @test pflag(test_driver) ≡ PFLAG

    @test Δ_max(test_driver) ≡ Δ_max(test_options)

    @test δ_tol(test_driver) ≡ δ_tol(test_options)

    @test ϵ_tol(test_driver) ≡ ϵ_tol(test_options)

    @test samples(test_driver) ≡ samples(test_options)

    @test max_iterations(test_driver) ≡ max_iterations(test_options)

    @test weave_level(test_driver) ≡ weave_level(test_options)

    @test log_level(test_driver) ≡ log_level(test_options)

    restricted_type_test(test_driver)
end


@testset "testing behavior" begin

    # Mutating test_options from test_driver - test update in test_options
    Δ_max!(test_driver, 1.0)
    @test Δ_max(test_options) ≡ 1.0

    δ_tol!(test_driver, 1.0)
    @test δ_tol(test_options) ≡ 1.0

    ϵ_tol!(test_driver, 1.0)
    @test ϵ_tol(test_options) ≡ 1.0

    samples!(test_driver, 2)
    @test samples(test_options) ≡ 2

    max_iterations!(test_driver, 0)
    @test max_iterations(test_options) ≡ 0

    weave_level!(test_driver, NONE)
    @test weave_level(test_options) ≡ NONE

    log_level!(test_driver, ERROR)
    @test log_level(test_options) ≡ ERROR


    # Mutating test_options from test_options - test update in test_driver
    Δ_max!(test_options, Δₘ)
    @test Δ_max(test_driver) ≡ Δₘ

    δ_tol!(test_options, δ)
    @test δ_tol(test_driver) ≡ δ

    ϵ_tol!(test_options, ϵ)
    @test ϵ_tol(test_driver) ≡ ϵ

    samples!(test_options, 2w)
    @test samples(test_driver) ≡ 2w

    max_iterations!(test_options, N)
    @test max_iterations(test_driver) ≡ N

    weave_level!(test_options, WEAVE_LEVEL)
    @test weave_level(test_driver) ≡ WEAVE_LEVEL

    log_level!(test_options, LOG_LEVEL)
    @test log_level(test_driver) ≡ LOG_LEVEL
end
