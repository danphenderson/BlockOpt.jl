@testset "Counter" begin
    counter = EvaluationCounter()

    @test evaluations(counter) ≡ 0

    @test increment!(counter, -1) ≡ 0

    @test increment!(counter) ≡ evaluations(counter) ≡ 1

    restricted_type_test(counter)
end


@testset "Timer" begin
    timer = EvaluationTimer()

    @test Δt(timer) ≡ 0.0

    on!(timer)
    sleep(0.5)
    off!(timer)

    @test Δt(timer) > 0.5

    restricted_type_test(timer)
end


@testset "Profile" begin
    profile = BlockOptProfile()

    @test Δt(trs_timer(profile)) ≡ Δt(ghs_timer(profile)) ≡ 0.0

    @test evaluations(trs_counter(profile)) ≡ evaluations(ghs_counter(profile)) ≡ 0

    restricted_type_test(profile)
end


@testset "Weaver" begin
    weaver = Weaver()

    @test weave_level(weaver) ≡ WEAVE_LEVEL

    weave!(weaver, :f_vals, 0.0)

    @test pop!(f_vals(weaver)) ≡ 0.0

    weave!(weaver, :∇f_norms, 0.0)

    @test pop!(∇f_norms(weaver)) ≡ 0.0

    weave!(weaver, :p_norms, 0.0)

    @test pop!(p_norms(weaver)) ≡ 0.0

    weave!(weaver, :Δ_vals, 0.0)

    @test pop!(Δ_vals(weaver)) ≡ 0.0

    weave!(weaver, :ρ_vals, 0.0)

    @test pop!(ρ_vals(weaver)) ≡ 0.0
end


@testset "Trace" begin

    test_trace = BlockOptTrace(test_model, test_driver)

    @testset "constructor test" begin

        @test model(test_trace) ≡ test_model

        @test driver(test_trace) ≡ test_driver

        @test isa(profile(test_trace), BlockOptProfile)

        @test isa(trs_timer(test_trace), EvaluationTimer)

        @test isa(ghs_timer(test_trace), EvaluationTimer)

        @test isa(trs_counter(test_trace), EvaluationCounter)

        @test isa(ghs_counter(test_trace), EvaluationCounter)

        @test isa(weaver(test_trace), Weaver)

        @test map(
            isempty,
            (
                f_vals(test_trace),
                ∇f_norms(test_trace),
                Δ_vals(test_trace),
                p_norms(test_trace),
                ρ_vals(test_trace),
            ),
        ) ≡ (true, true, true, true, true)


        @test weave_level(test_trace) ≡ weave_level(test_driver)

        @test log_level(test_trace) ≡ log_level(test_driver)

        @test isfile(io(test_trace))

        restricted_type_test(test_trace)
    end



    @testset "generated logging function test" begin

        # TODO: Visual confrimation suggests working as expected

    end

end
