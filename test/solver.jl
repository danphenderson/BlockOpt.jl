const quad_model = Model("Quadratic")

const n     = 20

const λs    = sort(n*rand(n))

const ∇²f   = Symmetric(begin Q = orth(randn(n, n)); Q'*diagm(λs)*Q end)

const ∇²f⁻¹ = inv(∇²f) # convergent term in sequence of block updates

objective!(quad_model, x -> 0.5*x'∇²f*x)   

gradient!(quad_model, (g, x) -> (g .= ∇²f*x))

formula!(quad_model, "\$ \\frac{1}{2} x^\\Top A x +  d^\\Top x\$")

const x₀       = initial_iterate!(quad_model, randn(n))

const f₀       = obj(quad_model, x₀)

const ∇f₀      = grad(quad_model, x₀)

const ∇f₀_norm = norm(∇f₀) 

const h₀       = ∇²f*∇f₀

const w        = Int(samples(test_driver)/2)


@testset "Backend" begin 
    b = BlockOptBackend(quad_model, test_driver) 


    initialize(b)


    @testset "initialize" begin

        @test b.fₖ ≈ f₀

        @test b.∇fₖ ≈ ∇f₀

        @test b.∇fₖ_norm ≈ ∇f₀_norm

        @test b.hₖ ≈ hess_sample(quad_model, x₀, b.∇fₖ) ≈ h₀

        @test b.Yₖ ≈ hess_sample(quad_model, x₀, b.Sₖ)  ≈ ∇²f * b.Sₖ
        
        @test b.Yₖ'*b.Sₖ ≈ b.Sₖ'*b.Yₖ

        @test b.Uₖ'*b.Vₖ ≈ b.Uₖ'*b.Vₖ

        @test b.Hₖ ≈ b.Hₖ'
    end


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

   
    # Walk through derivation of section 5: Trust Region Sub-Problem
    @testset "build_trs subroutine" begin

        @test b.P ≈ b.Qₖ' * b.Hₖ * b.Qₖ

        @test b.b ≈ b.Qₖ' * b.Hₖ * b.∇fₖ

        @test b.C ≈ b.Qₖ' * b.Hₖ^2 * b.Qₖ

        @test b.Qₖ'b.Qₖ ≈ zeros(samples(b) + 1, samples(b) + 1) + I

        @test mp(zeros(n)) ≈ 0.0

        @test mq(zeros(n)) ≈ 0.0

        @test ma(zeros(2w + 1)) ≈ 0.0

        @test rank(b.Hₖ) ≡ dimension(b)

        a = randn(2w + 1)

        @test sqrt(a' * b.C * a) ≈ norm(b.Hₖ * b.Qₖ * a)
        
        @test mq(b.Qₖ * a) ≈ ma(a)
    end


    solve_trs(b)


    @testset "solve_trs subroutine" begin

        @test b.qₖ ≈ b.Qₖ * b.aₖ

        @test b.pₖ ≈ b.Hₖ * b.qₖ

        @test ma(b.aₖ) ≈ mq(b.qₖ)

        @test ma(b.aₖ) ≥ mp(b.pₖ) # TODO: inequality obtained from convexity?

        @test ma(b.aₖ) ≤ 0.0       

        @test b.∇fₖ' * b.pₖ < 0.0     # descent direction test

        @test b.pₖ_norm ≈ b.Δₖ

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


    @test accept_trial(b) ≡ true


    @testset "accept_trial subroutine" begin

        local b = BlockOptBackend(quad_model, test_driver);

        b.ρ = 0.0;  @test accept_trial(b) ≡ false

        b.ρ = 1.0;  @test accept_trial(b) ≡ true      
    end


    @test pflag(b) ≡ false

    
    @testset "secantQN subroutine" begin

        # local b = BlockOptBackend(quad_model, test_driver);

        # initialize(b); solve_trs(b); build_trial(b); accept_trial(b)

        # sₖ = b.pₖ

        # yₖ = grad(b, b.xₜ) - b.∇fₖ

        # @test sₖ' * yₖ > 0.0    # curvature condition 

        # secantQN(b)

        # @test rank(b.Hₖ) ≡ n

        # @test b.Hₖ*yₖ ≈ sₖ
    end


    update_Sₖ(b)


    @testset "update_Sₖ subroutine" begin

        @test b.Sₖ'*b.Sₖ ≈ I

        @test rank(b.Sₖ) ≡ 2w - 1
    end


    gHS(b)


    @testset "gHS subroutine" begin

        ∇f₁ = grad(b, b.xₜ)

        h₁  = hess_sample(quad_model, b.xₖ,  ∇f₁)

        Y₁  = hess_sample(quad_model, b.xₖ, b.Sₖ)

        @test b.∇fₖ ≈ ∇f₁

        @test b.∇fₖ_norm ≈ norm(∇f₁)

        @test b.hₖ ≈ h₁

        @test b.Yₖ ≈ Y₁
        
        @test b.Yₖ'*b.Sₖ ≈ b.Sₖ'*b.Yₖ

        @test b.Uₖ'*b.Vₖ ≈ b.Uₖ'*b.Vₖ
    end


    blockQN(b)


    @testset "blockQN subroutine" begin

        @test b.Hₖ ≈ b.Hₖ'

        @test rank(b.Hₖ) ≡ n

        @test b.Hₖ * b.Vₖ ≈ b.Uₖ
    end


    update_Δₖ(b)


    @test b.Δₖ ≈ 2 * b.pₖ_norm


    @testset "update_Δₖ subroutine" begin

        local b = BlockOptBackend(quad_model, test_driver)

        b.ρ = 0.0; b.pₖ_norm = b.Δₖ = 1.0  # non-inclusive lower bound of ρ for shrinking Δ

        update_Δₖ(b);  @test b.Δₖ ≡ 1.0     

        b.ρ = 0.25; b.pₖ_norm = b.Δₖ = 1.0 # inclusive lower bound of ρ for keeping Δ

        update_Δₖ(b);  @test b.Δₖ ≡ 1.0      
        
        b.ρ = 0.75; b.pₖ_norm = b.Δₖ = 1.0 # non-inclusive lower bound of ρ for increasing Δ
        
        update_Δₖ(b);  @test b.Δₖ ≡ 1.0

        b.ρ = b.pₖ_norm = 0.9; b.Δₖ = 1.0  # increasing Δ boundary requirement

        update_Δₖ(b);  @test b.Δₖ ≡ 1.0
    end


    @testset "post iteration tests" begin
        @test size(b.C) ≡ size(b.P) ≡ (samples(b)+1, samples(b)+1) 
    
        @test size(b.b) ≡ size(b.aₖ) ≡ (samples(b) + 1,)
        
        @test size(b.Qₖ) ≡ (dimension(b), samples(b) + 1)   
        
        @test size(b.xₖ) ≡  size(b.∇fₖ) ≡ size(b.hₖ) ≡ (dimension(b),)

        @test size(b.pₖ) ≡ size(b.qₖ) ≡ size(b.xₜ) ≡ (dimension(b),)
        
        @test size(b.Sₖ) ≡ size(b.Yₖ) ≡ (dimension(b), samples(b) - 1)
        
        @test size(b.Uₖ) ≡ size(b.Vₖ) ≡ (dimension(b), samples(b))

        @test size(b.Hₖ) ≡ (dimension(b), dimension(b))
        
        @test map(issymmetric, (b.C, b.P, b.Hₖ)) ≡ (true, true, true)
    end
end


function main()
    b = BlockOptBackend(quad_model, test_driver)
end



