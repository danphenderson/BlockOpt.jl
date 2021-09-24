using Test, LinearAlgebra, Printf, BlockOpt, UncNLPrograms

function gHS_test(nlp; w=5, v::Bool=false)
    # test information 
    xₜ = nlp.x0 
    ∇²f = hessAD(nlp, xₜ) 
    ∇f  = grad(nlp, xₜ)

    # constructing tests 
    S = orth(rand(nlp.n, 2w-1))
    g, h, Y = gHS(nlp.g!, xₜ, S)

    test1 = norm(Y - ∇²f*S)
    test2 = norm(g - ∇f)
    test3 = norm(h - ∇²f*g)

    v && @printf "\n%s gHS Test n = %d, w = %d\n" nlp.name nlp.n w 
    v && @printf "-------------------------------------------\n"
    v && @printf "        ||Y   -   ∇²f*S||   = %1.3e\n"  test1	
    v && @printf "        ||g   -   ∇f(xₜ)||  = %1.3e\n" test2
    v && @printf "        ||h   - ∇²f(xₜ)g||  = %1.3e\n" test3

    return test1, test2, test3
end

function run_tests(v::Bool)
    pass = []

    for prog ∈ Programs()
        nlp = SelectProgram(prog)
        try
            test1, test2, test3 = gHS_test(nlp, v=v)
            @test test1 ≤ 1.0e-8
            @test test2 ≤ 1.0e-8
            @test test3 ≤ 1.0e-8
            push!(pass, prog)
        catch e
            isa(e, InterruptException) && return pass
            @show e
        end
    end	

    return pass
end