@testset "Backend Unit Tests:" begin

    @testset "Constructor" begin
        b = BlockOptBackend(test_model, test_driver)

        
        @testset "inhereted model methods" begin

            @test model(b) ≡ test_model

            @test b.xₖ ≈ initial_iterate(test_model)

            @test b.n ≡ dimension(test_model)

            @test obj(b, b.xₖ) ≈ obj(test_model, initial_iterate(test_model))

            @test grad!(b, similar(b.xₖ), b.xₖ) ≈ grad!(test_model, similar(b.xₖ), b.xₖ)

            @test grad(b, b.xₖ) ≈ grad(test_model, b.xₖ)
            
            @test dimension(b) ≡ dimension(test_model);
        end

       
        @testset "inhereted driver methods" begin

            @test driver(b) ≡ test_driver

            @test b.w ≡ Int(samples(test_driver)/2)

            @test QN_update(b) ≡ QN_update(test_driver)
        
            @test S_update(b)  ≡ S_update(test_driver)
            
            @test pflag(b) ≡ pflag(test_driver)
            
            @test samples(b) ≡ samples(test_driver)
             
            @test Δ_max(b) ≡ Δ_max(test_driver)
            
            @test δ_tol(b) ≡ δ_tol(test_driver)
            
            @test ϵ_tol(b) ≡ ϵ_tol(test_driver)

            @test max_iterations(b) ≡ max_iterations(test_driver);
        end


        @testset "backend accessors" begin

            @test fₖ(b) ≡ ∇fₖ_norm(b) ≡ pₖ_norm(b) ≡ Δₖ(b) ≡ ρ(b) ≡ 0.0 
           
            b.fₖ = 1.0

            @test fₖ(b) ≡ 1.0; b.fₖ = 0.0

            b.∇fₖ_norm = 1.0

            @test ∇fₖ_norm(b) ≡ 1.0; b.∇fₖ_norm = 0.0

            b.pₖ_norm = 1.0

            @test pₖ_norm(b) ≡ 1.0; b.pₖ_norm = 0.0

            b.Δₖ = 1.0

            @test Δₖ(b) ≡ 1.0; b.Δₖ = 0.0

            b.ρ = 1.0

            @test ρ(b) ≡ 1.0; b.ρ = 0.0;
        end


        @testset "initialization of fields" begin

            @test size(b.C) ≡ size(b.P) ≡ (samples(b)+1, samples(b)+1) 
            
            @test size(b.b) ≡ size(b.aₖ) ≡ (samples(b) + 1,)
            
            @test size(b.Qₖ) ≡ (dimension(b), samples(b) + 1)   
            
            @test size(b.xₖ) ≡  size(b.∇fₖ) ≡ size(b.hₖ) ≡ (dimension(b),)

            @test size(b.pₖ) ≡ size(b.qₖ) ≡ size(b.xₜ) ≡ (dimension(b),)
            
            @test size(b.Sₖ) ≡ size(b.Yₖ) ≡ (dimension(b), samples(b) - 1)
            
            @test size(b.Uₖ) ≡ size(b.Vₖ) ≡ (dimension(b), samples(b))

            @test size(b.Hₖ) ≡ (dimension(b), dimension(b))
            
            @test map(issymmetric, (b.C, b.P, b.Hₖ)) ≡ (true, true, true);
        end
    end


    # @testset "Memory manipulation" begin
    #     b = BlockOptBackend(test_model, test_driver)

    #     # manipulates fₖ, Δₖ, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, ∇fₖ, hₖ, ∇fₖ_norm
    #     @testset "initialize subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         initialize(b)

    #         @test !(fₖ, Δₖ, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, ∇fₖ, hₖ, ∇fₖ_norm ≈
    #         b.fₖ, b.Δₖ, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, b.Hₖ, b.∇fₖ, b.hₖ, b.∇fₖ_norm)

    #         @test xₖ, pₖ, xₜ, fₜ, ρ, pₖ_norm, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.pₖ_norm, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # manipulates P, b, C
    #     @testset "build_trs subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         build_trs(b)

    #         @test !(P, b, C ≈ P, b, C)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.aₖ, b.qₖ
    #     end


    #     # manipulates aₖ, qₖ, pₖ, pₖ_norm
    #     @testset "solve_trs subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         solve_trs(b)

    #         @test !(aₖ, qₖ, pₖ, pₖ_norm ≈ b.aₖ, b.qₖ, b.pₖ, b.pₖ_norm)   

    #         @test xₖ, ∇fₖ, hₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C
    #     end


    #     # manipulates xₜ, fₜ, ρ
    #     @testset "build_trial subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         build_trial(b)

    #         @test !(xₜ, fₜ, ρ ≈ b.xₜ, b.fₜ, b.ρ)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, fₖ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.fₖ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # manipulates Sₖ
    #     @testset "update_Sₖ subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         update_Sₖ(b)

    #         @test !(Sₖ ≈ b.Sₖ)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # manipulates ∇fₖ_norm, ∇fₖ, hₖ, Yₖ Uₖ, Vₖ
    #     @testset "gHS subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         gHS(b)

    #         @test !(∇fₖ_norm, ∇fₖ, hₖ, Yₖ, Uₖ, Vₖ ≈ b.∇fₖ_norm, b.∇fₖ, b.hₖ, b.Yₖ, b.Uₖ, b.Vₖ)

    #         @test xₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, pₖ_norm, Sₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.pₖ_norm, b.Sₖ, b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # manipulates Hₖ
    #     @testset "blockQN subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         blockQN(b)

    #         @test !(Hₖ ≈ b.Hₖ)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # manipulates Hₖ
    #     @testset "secantQN subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         secantQN(b)

    #         @test !(Hₖ ≈ b.Hₖ)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # may manipulate xₜ, fₜ
    #     @testset "accept_trial subroutine" begin 
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         accept_trial(b)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, fₖ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.fₖ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # may manipulate Δₖ
    #     @testset "update_Δₖ subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b

    #         update_Δₖ(b)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # no memory manipulation
    #     @testset "terminal subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b
           
    #         terminal(b, 0)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ
    #     end


    #     # no memory manipulation
    #     @testset "pflag subroutine" begin
    #         @unpack xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ = b
            
    #         update_Δₖ(b)

    #         @test xₖ, ∇fₖ, hₖ, pₖ, xₜ, fₖ, fₜ, ρ, Δₖ, ∇fₖ_norm, pₖ_norm, Sₖ, Yₖ, Uₖ, Vₖ, Hₖ, Qₖ, P, b, C, aₖ, qₖ ≈
    #         b.xₖ, b.∇fₖ, b.hₖ, b.pₖ, b.xₜ, b.fₖ, b.fₜ, b.ρ, b.Δₖ, b.∇fₖ_norm, b.pₖ_norm, b.Sₖ, b.Yₖ, b.Uₖ, b.Vₖ, 
    #         b.Hₖ, b.Qₖ, b.P, b.b, b.C, b.aₖ, b.qₖ       
    #     end
    # end


    @testset "Edge cases" begin

        @testset "terminal subroutine" begin
             
            b = BlockOptBackend(test_model, test_driver)

            b.∇fₖ_norm = ϵ_tol(b) + 1.0 

            @test terminal(b, max_iterations(b) - 1) ≡ false # terminal iteration

            @test terminal(b, max_iterations(b)) ≡ true      # exit condition

            b.∇fₖ_norm = ϵ_tol(b)

            @test terminal(b, max_iterations(b) - 1) ≡ false  # not good enough

            b.∇fₖ_norm = ϵ_tol(b) - eps(Float64)

            @test terminal(b, max_iterations(b) - 1) ≡ true  # convergence reached
        end

        @testset "terminal subroutine" begin

            b = BlockOptBackend(test_model, test_driver)
            
            # TODO: Return b and pipeline above operations. 
            initialize(b); build_trs(b); solve_trs(b); build_trial(b); 

            b.ρ = 0.0
            
            @test !accept_trial(b) && !(b.xₖ ≈ b.xₜ) && !(b.fₖ ≈ b.fₜ)

            b.ρ = 1.0

            @test accept_trial(b) && (b.xₖ ≈ b.xₜ) && (b.fₖ ≈ b.fₜ)
        end


        @testset "update_Δₖ subroutine" begin

            b = BlockOptBackend(test_model, test_driver)
    
            b.ρ = 0.0; b.pₖ_norm = b.Δₖ = 1.0  # non-inclusive lower bound of ρ for shrinking Δ
    
            update_Δₖ(b);  @test b.Δₖ ≈ 1.0     
    
            b.ρ = 0.25; b.pₖ_norm = b.Δₖ = 1.0 # inclusive lower bound of ρ for keeping Δ
    
            update_Δₖ(b);  @test b.Δₖ ≈ 1.0      
            
            b.ρ = 0.75; b.pₖ_norm = b.Δₖ = 1.0 # non-inclusive lower bound of ρ for increasing Δ
            
            update_Δₖ(b);  @test b.Δₖ ≈ 1.0
    
            b.ρ = b.pₖ_norm = 0.9; b.Δₖ = 1.0  # increasing Δ boundary requirement
    
            update_Δₖ(b);  @test b.Δₖ ≈ 1.0
        end
    end
end


@testset "Backend Behavior Tests:" begin
    b = BlockOptBackend(test_model, test_driver)


    initialize(b)


    @testset "initialize subroutine" begin

        @test b.fₖ ≈ obj(b, b.xₖ)

        @test b.∇fₖ ≈ grad(b, b.xₖ)

        @test b.∇fₖ_norm ≈ norm(grad(b, b.xₖ))

        @test b.hₖ ≈ hess_sample(test_model, b.xₖ, b.∇fₖ)

        @test b.Yₖ ≈ hess_sample(test_model, b.xₖ, b.Sₖ)
        
        @test b.Yₖ'*b.Sₖ ≈ b.Sₖ'*b.Yₖ

        @test b.Uₖ'*b.Vₖ ≈ b.Uₖ'*b.Vₖ

        @test b.Hₖ ≈ b.Hₖ'

        @test rank(b.Hₖ) ≡ dimension(b)
    end

    iterations = 0

    while !terminal(b, iterations)

        iterations+=1


        build_trs(b)


        """
        Equation 5.1: ``pₖ = arg min model_p(p) : ||p|| < Δ,``    
        for p ∈ ℜⁿ; the standard n-dimensional trust-region subproblem.
        """
        mp(p) = 0.5 * p' * b.Hₖ * p + b.∇fₖ'p
    
        
        """ 
        Equation 5.2: ``qₖ = arg min model_q(q) : ||q|| < Δ,``
        for q ∈ ℜⁿ; when Hₖ is full rank, pₖ = Hₖqₖ.
        """
        mq(q) = 0.5 * q' * b.Hₖ * q + (b.Hₖ * b.∇fₖ)'q
    
    
        """
        Equation 5.3: ``aₖ = arg min model_a(a) : ||Hₖ Qₖ aₖ|| < Δ,``  
        for a ∈ ℜ²ʷ⁺¹; solve to obtain step pₖ = HₖQₖaₖ and
        """
        ma(a) = 0.5 * a' * b.P * a + b.b'a


        @testset "build_trs subroutine" begin

            @test b.P ≈ b.Qₖ' * b.Hₖ * b.Qₖ

            @test b.b ≈ b.Qₖ' * b.Hₖ * b.∇fₖ

            @test b.C ≈ b.Qₖ' * b.Hₖ^2 * b.Qₖ

            Qₖ = [b.hₖ/b.∇fₖ_norm  b.∇fₖ/b.∇fₖ_norm  b.Yₖ]

            # TODO: @test b.Qₖ preserves ls solution of Qₖ's null space 

            @test b.Qₖ ≈ orth(Qₖ)

            @test b.Qₖ'b.Qₖ ≈ zeros(samples(b) + 1, samples(b) + 1) + I

            @test mp(zeros(dimension(b))) ≈ 0.0

            @test mq(zeros(dimension(b))) ≈ 0.0

            @test ma(zeros(samples(b) + 1)) ≈ 0.0

            a = randn(2w + 1)

            @test sqrt(a' * b.C * a) ≈ norm(b.Hₖ * b.Qₖ * a)
        end


        solve_trs(b)


        @testset "solve_trs subroutine" begin

            @test b.qₖ ≈ b.Qₖ * b.aₖ

            @test b.pₖ ≈ b.Hₖ * b.qₖ

            @test ma(b.aₖ) ≈ mq(b.qₖ)

            # TODO: @test ma(b.aₖ) to mp(b.pₖ) 

            @test ma(b.aₖ) ≤ 0.0       

            @test b.∇fₖ' * b.pₖ < 0.0  

            @test sqrt(b.aₖ' * b.C * b.aₖ) ≈ b.pₖ_norm
        end


        build_trial(b)
    

        @testset "build_trial subroutine" begin
    
            @test b.xₜ ≈ b.xₖ + b.pₖ
    
            @test b.fₜ ≈ obj(b, b.xₜ)
    
            model_reduction = ma(b.aₖ)
    
            actual_reduction = b.fₜ - b.fₖ
    
            @test model_reduction ≤ 0.0
            
            @test actual_reduction ≤ 0.0
    
            @test b.ρ ≈ actual_reduction / model_reduction
        end


        successful_trial = accept_trial(b)


        @test successful_trial ≡ (b.ρ > 0.0)


        @test pflag(b) ≡ pflag(test_driver)


        successful_trial && pflag(b) && @testset "secantQN subroutine" begin

            sₖ = b.pₖ
    
            yₖ = grad(b, b.xₜ) - b.∇fₖ
    
            @test sₖ' * yₖ > 0.0    # curvature condition 
    
            secantQN(b)
    
            @test rank(b.Hₖ) ≡ n
    
            @test b.Hₖ*yₖ ≈ sₖ

            true
        end


        successful_trial && @testset "update_Sₖ subroutine" begin

            update_Sₖ(b)

            @test b.Sₖ'*b.Sₖ ≈ I
    
            @test rank(b.Sₖ) ≡ 2w - 1

            true
        end


        successful_trial && @testset "gHS subroutine" begin

            gHS(b)
    
            @test b.∇fₖ ≈ grad(b, b.xₜ)
    
            @test b.∇fₖ_norm ≈ norm(grad(b, b.xₜ))
    
            @test b.hₖ ≈ hess_sample(test_model, b.xₖ, b.∇fₖ)
    
            @test b.Yₖ ≈ hess_sample(test_model, b.xₖ, b.Sₖ)
            
            @test b.Yₖ'*b.Sₖ ≈ b.Sₖ'*b.Yₖ

            @test b.Uₖ ≈ [b.Sₖ  b.∇fₖ / b.∇fₖ_norm] 

            @test b.Vₖ ≈ [b.Yₖ  b.hₖ / b.∇fₖ_norm]
    
            @test b.Uₖ'*b.Vₖ ≈ b.Uₖ'*b.Vₖ

            true
        end


        successful_trial && @testset "blockQN subroutine" begin

            blockQN(b)

            @test rank(b.Hₖ) ≡ n
    
            @test b.Hₖ ≈ b.Hₖ'

            @test b.Hₖ * b.hₖ ≈ b.∇fₖ  # possible typo eqution 5.3 
    
            @test b.Hₖ * b.Vₖ ≈ b.Uₖ

            @test b.Hₖ * b.Yₖ ≈ b.Sₖ  

            true
        end


        update_Δₖ(b)
        
    end

    nothing
end