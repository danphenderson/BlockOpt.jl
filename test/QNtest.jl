using Test, LinearAlgebra, Printf, BlockOpt

"""
    QNDriver

Holds unit test information for the Quasi-Newton Updates.
"""
Base.@kwdef struct QNTest
    name::String
    n::Int
    w::Int
    noise::Float64
    δ        = 1.0e-12
    ∇²f      = begin A = rand(n, n);   Symmetric(A*A' + I) end 
    ∇²f⁻¹    = inv(A)
    H        = zeros(n,n) + I
    # H        = begin H = ∇²f⁻¹ + noise*rand(n,n);  Symmetric(H+H') end
    U        = begin U = randn(n, 2w); Matrix(qr(U).Q) end
    V        = ∇²f*U
end


"""
    qn_requirements_test

The bSR1 and bPSB indefinite Quasi-Newton block updates requires input:
    H ∈ ℜⁿˣⁿ     such that Hᵀ = H
    U,V ∈ ℜⁿˣ²ʷ  such that UᵀV = VᵀU
"""
function qn_requirements_test(H, U, V)
    H_test  =  issymmetric(H)
    UV_test = U'V ≈ V'U
    return H_test, UV_test
end


"""
    qn_secant_test

The bSR1 and bPSB updates must satisfy the block inverse secant condition:
    HnewV = U

Where Hnew is the updated inverse approximation based upon the curvature
information of V, generated in the directions of U's columns. When using
block updates in a Least-Squares setting, this is known as the 
multi-secant condition.
"""
function qn_secant_test(Hnew, U, V)
    secant_test = Hnew*V ≈ U
    return secant_test
end


"""
    qn_convergence_test
    
When H⁻¹ is approximating a positive-definite Hessian ∇²f, it is expected
that H converges to ∇²f⁻¹ when repeatedly updating H with curvature information
obtained from sampling ∇²f in orthoganol sequence of directions.

Before each update a qn_requirements_test is performed.
After each update a qn_secant_test is performed. 
"""
function qn_convergence_test(QN::Function, test::QNTest; max_itr=10, tol = 1.0e-7)
	∇²f, ∇²f⁻¹, H, U, V, δ = test.∇²f, test.∇²f⁻¹, test.H, test.U, test.V, test.δ

    rel = norm(∇²f⁻¹)

    i, error = 0, norm(∇²f⁻¹ - H)/rel

	@printf "    Update: Hₖ = %s(Hₖ₋₁, U, V, δ)\n" QN
	@printf "          Initial ||∇²f⁻¹ - H|| = %1.5e\n" error

	while error > tol && (i+=1) < max_itr 
        println("κ(∇²f) = $(cond(∇²f)), κ(H) = $(cond(H))")

        # test
        H_test, V_test = qn_requirements_test(H, U, V)
        H = QN(H, U, V, δ)
        secant_test = qn_secant_test(H, U, V)
        error = norm(∇²f⁻¹ - H)/rel

        # # temporary
        # try
        #     @assert H_test == true
        #     @assert V_test == true 
        #     @assert secant_test == true
        # catch e
        #     println(e)
        # end
        

        # obtain supplemental directions 
        U = orth(V - U*(U' * V))
        V = ∇²f*U
	end

    pass = (i < max_itr ? true : false)
	@printf "          Final   ||∇²f⁻¹ - H|| = %1.5e\n" error
	@printf "    %s: Hₖ %s A⁻¹ in %d iterations\n" (pass ? "SUCCESS" : "FAILURE") (pass ? "↛" : "→") i
	@printf "    ----------------------------------------\n"
	return error ≤ tol
end

function run_tests()
    n, w, name = 10, 4, "QN convergence to ill-condition SPD A"
	TS = [QNTest(name = name, n = n, w = w, noise = 0.05),  QNTest(name = name, n = n, w = w, noise = 0.1)]
	for test ∈ TS
		qn_convergence_test(bSR1, test)
		qn_convergence_test(bPSB, test)
	end
end

# @testset "qn_convergence_test" begin
#     n, w, name = 10, 3, "QN convergence to ill-condition SPD A"
# 	TS = [QNTest(name = name, n = n, w = w, noise = 0.1),  QNDriver(name = name, n = n, w = w, noise = 1.0)]
# 	for test ∈ TS
# 		@test qn_convergence_test(BFGS, test)
# 		@test qn_convergence_test(SR1, test)
# 	end
# end