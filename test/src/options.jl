@testset "testing constructor" begin

    @test Δ_max(test_options) ≡ Δₘ

    @test δ_tol(test_options) ≡ δ

    @test samples(test_options) ≡ 2w

    @test max_iterations(test_options) ≡ N

    @test weave_level(test_options) ≡ WEAVE_LEVEL

    @test log_level(test_options) ≡ LOG_LEVEL

    restricted_type_test(test_options)
end


@testset "testing behavior" begin

    options = DriverOptions()

    # Mutating option fields only if positive 
    @test !(Δ_max!(options, 0.0) ≡ 0.0)

    @test !(δ_tol!(options, 0.0) ≡ 0.0)

    @test !(ϵ_tol!(options, 0.0) ≡ 0.0)

    @test !(samples!(options, 0) ≡ 0)

    @test !(samples!(options, 1) ≡ 1)

    @test Δ_max!(options, 1.0) ≡ 1.0

    @test δ_tol!(options, 1.0) ≡ 1.0

    @test ϵ_tol!(options, 1.0) ≡ 1.0

    @test samples!(options, 2) ≡ 2

    @test weave_level!(options, NONE) ≡ NONE

    @test log_level!(options, ERROR) ≡ ERROR
end
