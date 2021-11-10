@testset "Simulation Unit Tests:" begin


    s = Simulation(test_model, test_driver)


    @test isa(trace(s), BlockOptTrace)
        
    @test isa(backend(s), BlockOptBackend)


    @testset "inhereted methods" begin

        @test isa(trs_timer(s), EvaluationTimer)

        @test Δt(trs_timer(s)) ≡ 0.0

        @test isa(trs_counter(s), EvaluationCounter)

        @test evaluations(trs_counter(s)) ≡ 0

        @test isa(ghs_timer(s), EvaluationTimer)

        @test Δt(ghs_timer(s)) ≡ 0.0

        @test isa(ghs_counter(s), EvaluationCounter)

        @test evaluations(ghs_counter(s)) ≡ 0

        @test weave!(s, :f_vals, 0.0) ≈ [0.0]

        @test weave!(s, :∇f_norms, 1.0) ≈ [1.0]

        @test weave!(s, :Δ_vals, 2.0) ≈ [2.0]

        @test weave!(s, :p_norms, 3.0) ≈ [3.0]

        @test weave!(s, :ρ_vals, 4.0) ≈ [4.0]

        @test pop!(f_vals(s)) ≈ 0.0
        
        @test pop!(∇f_norms(s)) ≈ 1.0
        
        @test pop!(Δ_vals(s)) ≈ 2.0
       
        @test pop!(p_norms(s)) ≈ 3.0
        
        @test pop!(ρ_vals(s)) ≈ 4.0

        @test weave!(s, f_vals, 0.0) ≈ [0.0]

        @test weave!(s, ∇f_norms, 1.0) ≈ [1.0]

        @test weave!(s, Δ_vals, 2.0) ≈ [2.0]

        @test weave!(s, p_norms, 3.0) ≈ [3.0]

        @test weave!(s, ρ_vals, 4.0) ≈ [4.0]

        @test weave_level(s) ≡ weave_level(test_driver)

        @test fₖ(s) ≈ ∇fₖ_norm(s) ≈ pₖ_norm(s) ≈ Δₖ(s) ≈ ρ(s) ≈ 0.0

        @test log_level(s) ≡ log_level(test_driver)

        @test isfile(io(s))

        info!(s,  "This is an info! message.")
        
        debug!(s, "This is an debug! message.")
        
        warn!(s,  "This is an warn! message.")
        
        error!(s, "This is an error! message.")

        # Currently, the statements below print to console. Fix. 

        # info!(s,  "Simulation initilaized by:\\n", test_model, test_driver)

        # info!(s,  "Simulation initilized trace and backend:\\n", trace(s), backend(s))
       
        restricted_type_test(s);
    end

     
    @testset "edge case testing" begin


    end

    nothing
end


@testset "Simulation Behavior Tests:" begin

    max_iterations!(test_driver, 4)

    s = Simulation(test_model, test_driver)

    @testset "initialize subroutine" begin
        
        @test evaluations(ghs_counter(s)) ≡ 0

        initialize(s)
        
        @test evaluations(ghs_counter(s)) ≡ 1
    end

    i = 0

    while !terminal(s)


        build_trs(s)
  

        @testset "solve_trs subroutine" begin

            k = evaluations(trs_counter(s))

            elapsed = Δt(trs_timer(s))

            solve_trs(s)

            @test evaluations(trs_counter(s)) ≡ k + 1

            @test Δt(trs_timer(s)) > elapsed
        end


        build_trial(s)


        successful_trial = accept_trial(s)
        

        @testset "accept_trial subroutine" begin

            if successful_trial

                @test last(Δ_vals(s)) ≈ Δₖ(s)

                @test last(ρ_vals(s)) ≈ ρ(s)

                @test last(p_norms(s)) ≈ pₖ_norm(s)
            end

            @test last(f_vals(s)) ≈ fₖ(s) # always holds 

            @test last(∇f_norms(s)) ≈ ∇fₖ_norm(s) # always holds
        end


        successful_trial && pflag(s) && secantQN(s)


        successful_trial && update_Sₖ(s)


        successful_trial && @testset "gHS subroutine" begin

            cost = evaluations(ghs_counter(s))

            elapsed = Δt(ghs_timer(s))

            ∇f_norm = ∇fₖ_norm(s)

            gHS(s)

            @test !(last(∇f_norms(s)) ≈ ∇f_norm)

            @test evaluations(ghs_counter(s)) ≡ cost + 1

            @test Δt(ghs_timer(s)) > elapsed
        end


        successful_trial && blockQN(s)
        

        update_Δₖ(s)

        i += 1
    end

    @test last(∇f_norms(s)) ≈ ∇fₖ_norm(s)

    @test last(f_vals(s)) ≈ fₖ(s)

    if max_iterations(backend(s)) > evaluations(trs_counter(s)) # implying convergence

        @test last(Δ_vals(s)) ≈ Δₖ(s)

        @test last(ρ_vals(s)) ≈ ρ(s)

        @test last(p_norms(s)) ≈ pₖ_norm(s)

        @test ∇fₖ_norm(s) < ϵ_tol(backend(s))
    end

    return nothing
end