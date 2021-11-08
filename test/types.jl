
function restricted_type_test(type)
    @test_throws AccessError type.afield
    @test propertynames(type) ≡ ()
    return nothing
end


const test_model = Model("Testing")


@testset "Model" begin
    # Expected test values after loading test_model
    n         = 100   
    f(x)      = sqrt(x'x)
    ∇f!(g, x) = (g .= x)
    ∇²f(x)    = zeros(n, n) + I 
    x₀        = rand(n)
    f₀        = f(x₀)
    ∇f₀       = ∇f!(similar(x₀), x₀)
    ∇²f₀      = ∇²f(x₀)
    J∇f₀      = ∇²f₀ * ∇f₀ 
    Name      = "Testing"
    LaTex     = "\$f(x) = ||x||_2^2\$" 
    
    @test name(test_model) ≡ Name

    @test final(test_model) ≡ false

    @test isdir(directory(test_model))

    @test objective(test_model)       ≡
          gradient(test_model)        ≡
          formula(test_model)         ≡
          dimension(test_model)       ≡
          initial_iterate(test_model) ≡ missing

    @test final(test_model) ≡ false

    @test objective!(test_model, f) ≡ 
          objective(test_model)     ≡ f  

    @test final(test_model) ≡ false

    @test gradient!(test_model, ∇f!) ≡
          gradient(test_model)       ≡ ∇f!

    @test final(test_model) ≡ true

    @test !isa(objective!(test_model, missing), Missing)

    @test !isa(gradient!(test_model,  missing), Missing)

    @test initial_iterate!(test_model, x₀) ≡ 
          initial_iterate(test_model)      ≡ x₀

    @test dimension(test_model) ≡ n

    @test formula!(test_model, LaTex) ≡
          formula(test_model)         ≡ LaTex

    @test obj(test_model, x₀) ≈ f₀

    @test grad!(test_model, similar(x₀), x₀) ≈ ∇f₀;

    @test grad(test_model, x₀) ≈ ∇f₀

    @test hessAD(test_model, x₀) ≈ ∇²f₀

    @test hess_sample(test_model, x₀, ∇f₀) ≈ J∇f₀
end


const test_options = DriverOptions()


@testset "Options" begin
    # Expected default DriverOption test values
    Δₘ          = 100.0
    δ           = 1.0e-12
    ϵ           = 10.0e-6
    w           = 3
    N           = 2000
    WEAVE_LEVEL = ALL
    LOG_LEVEL   = INFO

    # Mutating option fields 
    @test Δ_max!(test_options, 0.0) ≡ 0.0
    
    @test δ_tol!(test_options, 0.0) ≡ 0.0
    
    @test ϵ_tol!(test_options, 0.0) ≡ 0.0
    
    @test samples!(test_options, 0) ≡ 0
    
    @test max_iterations!(test_options, 0) ≡ 0
    
    @test weave_level!(test_options, NONE) ≡ NONE
    
    @test log_level!(test_options, ERROR) ≡ ERROR

    # Reseting option fields to defaults 
    @test Δ_max!(test_options, Δₘ) ≡ Δ_max(test_options) ≡ Δₘ
    
    @test δ_tol!(test_options, δ) ≡ δ_tol(test_options) ≡ δ

    @test ϵ_tol!(test_options, ϵ) ≡ ϵ_tol(test_options) ≡ ϵ

    @test samples!(test_options, 2w) ≡ samples(test_options) ≡ 2w

    @test max_iterations!(test_options, N) ≡ max_iterations(test_options) ≡ N

    @test weave_level!(test_options, WEAVE_LEVEL) ≡ weave_level(test_options) ≡ WEAVE_LEVEL

    @test log_level!(test_options, LOG_LEVEL) ≡ log_level(test_options) ≡ LOG_LEVEL

    restricted_type_test(test_options);
end


const test_driver = Driver()


@testset "Driver" begin
    # Expected default Driver test values
    S_UPDATE  = C
    QN_UPDATE = SR1
    PFLAG = false

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
    
    restricted_type_test(test_driver);
end

@testset "Timer" begin
    timer = EvaluationTimer()
        
    @test Δt(timer) ≡ 0.0

    on!(timer); sleep(0.5); off!(timer)

    @test Δt(timer) > 0.5

    restricted_type_test(timer);
end


@testset "Counter" begin
    counter = EvaluationCounter()

    @test current_count(counter) ≡ 0
    
    @test increment!(counter, -1) ≡ 0

    @test increment!(counter)    ≡ 
          current_count(counter) ≡ 1

    restricted_type_test(counter)
end


@testset "Profile" begin
    profile = BlockOptProfile()

    @test Δt(trs_timer(profile)) ≡
          Δt(ghs_timer(profile)) ≡ 0.0
   
    @test current_count(trs_counter(profile)) ≡
          current_count(ghs_counter(profile)) ≡ 0
 
    restricted_type_test(profile)
end


@testset "Weaver" begin
    weaver = Weaver(weave_level(test_driver))

    @test weave_level(weaver) ≡ weave_level(test_driver)

    weave!(weaver, :f_vals, 0.0)

    @test pop!(weaver.f_vals) ≡ 0.0
end


@testset "Trace" begin
    trace = BlockOptTrace(test_model, test_driver)

    @test model(trace) ≡ test_model

    @test driver(trace) ≡ test_driver

    @test isa(weaver(trace), Weaver)

    @test weave_level(trace) ≡ weave_level(test_driver)

    @test log_level(trace) ≡ log_level(test_driver)

    @test directory(trace) ≡ directory(test_model)

    @test isfile(io(trace))

    @test isa(profile(trace), BlockOptProfile)

    @test Δt(trs_timer(trace)) ≡ 0.0

    @test current_count(trs_counter(trace)) ≡ 0
    
    @test Δt(ghs_timer(trace)) ≡ 0.0

    @test current_count(trs_counter(trace)) ≡ 0

    restricted_type_test(trace)
end


@testset "Backend" begin
    b = BlockOptBackend(test_model, test_driver)

    x0 = initial_iterate(test_model)

    @test model(b) ≡ test_model

    @test driver(b) ≡ test_driver

    @test obj(b, b.xₖ) ≈ obj(test_model, initial_iterate(test_model))

    @test grad!(b, similar(b.xₖ), b.xₖ) ≈ grad(test_model, initial_iterate(test_model)) 
    
    @test dimension(b) ≡ dimension(test_model)
    
    @test QN_update(b) ≡ QN_update(test_driver)
    
    @test S_update(b) ≡ S_update(test_driver)
    
    @test pflag(b) ≡ pflag(test_driver)
    
    @test samples(b) ≡ samples(test_driver)
    
    @test Δ_max(b) ≡ Δ_max(test_driver)
    
    @test δ_tol(b) ≡ δ_tol(test_driver)
    
    @test ϵ_tol(b) ≡ ϵ_tol(test_driver)
    
    @test max_iterations(b) ≡ max_iterations(test_driver)

    @test size(b.C) ≡ size(b.P) ≡ (samples(b)+1, samples(b)+1) 
    
    @test size(b.b) ≡ size(b.aₖ) ≡ (samples(b) + 1,)
    
    @test size(b.Qₖ) ≡ (dimension(b), samples(b) + 1)   
    
    @test size(b.xₖ) ≡  size(b.∇fₖ) ≡ size(b.hₖ) ≡ (dimension(b),)

    @test size(b.pₖ) ≡ size(b.qₖ) ≡ size(b.xₜ) ≡ (dimension(b),)
    
    @test size(b.Sₖ) ≡ size(b.Yₖ) ≡ (dimension(b), samples(b) - 1)
    
    @test size(b.Uₖ) ≡ size(b.Vₖ) ≡ (dimension(b), samples(b))

    @test size(b.Hₖ) ≡ (dimension(b), dimension(b))
    
    @test map(issymmetric, (b.C, b.P, b.Hₖ)) ≡ (true, true, true)
    # TODO: Test, orthogonality of S and anything else in constructor
end







