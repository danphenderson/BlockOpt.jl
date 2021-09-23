using Test, LinearAlgebra, Printf, QuasiNewtonHS, UncNLPrograms 
# TODO: add more comprehensive testing

function gAD_test(nlp; w=5, v::Bool=false)
    # test information
    xₜ = nlp.x0
    ∇f  = grad(nlp, xₜ)

    # constructing tests 
    S    = orth(rand(nlp.n, 2w-1))
    g, Y = gAD(nlp.g!, xₜ, S)
    test1 = norm(∇f - g) 

    v && @printf "\n%s gAD Test at default iterate n = %d, w = %d\n" nlp.name nlp.n w
    v && @printf "-------------------------------------------\n"
    v && @printf "        ||∇f    - g||  = %1.3e\n" test1

    return test1
end

function gHS_test(nlp; w=5, v::Bool=false)
    # test information 
    xₜ = nlp.x0 
    ∇²f = hessAD(nlp, xₜ) 

    # constructing tests 
    S = orth(rand(nlp.n, 2w-1))
    g, h, Y = gHS(nlp.g!, xₜ, S)
    U = [S g]
    V = [Y h]
    test1 = norm(Y - ∇²f*S)
    test2 = norm(U'*∇²f*U - U'V)
    test3 = norm(h - ∇²f*g) 



    v && @printf "\n%s gHS Test n = %d, w = %d\n" nlp.name nlp.n w 
    v && @printf "-------------------------------------------\n"
    v && @printf " Positive Definite Hessian? %s Symmetric? %s\n" isposdef(∇²f) issymmetric(∇²f) 

    v && @printf "        ||V - ∇²f*U|| = %1.3e\n" test1	

    v && @printf "        ||U'*∇²f*U - U'V||  = %1.3e\n" test2

    v && @printf "        ||h   - ∇²f*g||  = %1.3e\n" test3

    return test1, test2, test3
end

function run_tests(v::Bool)
    gADpass = []
    gHSpass = []

    for prog ∈ Programs()
        nlp = SelectProgram(prog)
        try
            test1 = gAD_test(nlp, v=v)
            @test test1 ≤ 1.0e-4	
            test1, test2, test3 = gHS_test(nlp, v=v)
            @test test1 ≤ 1.0e-4
            @test test2 ≤ 1.0e-4
            @test test3 ≤ 1.0e-4
            push!(gHSpass, prog)
            push!(gADpass, prog)
        catch e
            isa(e, InterruptException) && return gADpass, gHSpass
            @show e
        end
    end	

    return gADpass, gHSpass
end