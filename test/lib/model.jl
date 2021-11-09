@testset "Model" begin

    @testset "constructor test" begin

        @test name(test_model) ≡ NAME

        @test final(test_model) ≡ false

        @test isdir(directory(test_model))

        @test isa(objective(test_model), Missing)

        @test isa(gradient(test_model), Missing)

        @test isa(initial_iterate(test_model), Missing)

        @test isa(dimension(test_model), Missing)

        @test isa(formula(test_model), Missing)
    end


    @testset "loading model test" begin

        @test objective!(test_model, f) ≡ f 

        @test final(test_model) ≡ false

        @test gradient!(test_model, ∇f!) ≡ ∇f!

        @test final(test_model) ≡ true

        @test !isa(objective!(test_model, missing), Missing)

        @test !isa(gradient!(test_model,  missing), Missing)

        @test initial_iterate!(test_model, x₀) ≡ x₀

        @test formula!(test_model, LaTex) ≡ LaTex
    end


    @testset "loaded model test" begin

        @test objective(test_model) ≡ f
        
        @test gradient(test_model) ≡ ∇f!  

        @test initial_iterate(test_model) ≡ x₀
        
        @test dimension(test_model) ≡ n 

        @test formula(test_model) ≡ LaTex

        @test obj(test_model, x₀) ≈ f₀

        @test grad!(test_model, similar(x₀), x₀) ≈ ∇f₀
    
        @test grad(test_model, x₀) ≈ ∇f₀
    
        @test hessAD(test_model, x₀) ≈ ∇²f
    
        @test hess_sample(test_model, x₀, ∇f₀) ≈ h₀
    end
end