using Test, LinearAlgebra, Printf, BlockOpt

"""
    QNDriver

Holds unit test information for the Quasi-Newton Updates.
We initialize A ∈ ℜⁿˣⁿ to be symmetric positive definite with eigenvalues
uniformly distributed from [0,10]. We use the scaled identity as the 
initial approximation to the A⁻¹. The scalling factor is α, the 1 over the mean
of the eigenvalues of A. This is a various generous test!
"""
Base.@kwdef struct QNTest
    name::String
    n::Int
    w::Int
    δ        = 1.0e-12
    λs       = sort(n*rand(n))
    A        = begin Q = orth(randn(n, n)); Q'*diagm(λs)*Q end 
    Ainv     = inv(A)
    U        = orth(rand(n, w)) # setting this to n gives convergence in one iteration
    V        = A*U
    H        = (zeros(n,n) + I)*1/(sum(λs[1:end])/n)
end


"""
    qn_requirements_test

The bSR1 and bPSB indefinite Quasi-Newton block updates requires input:
    H ∈ ℜⁿˣⁿ     such that Hᵀ = H
    U,V ∈ ℜⁿˣ²ʷ  such that UᵀV = VᵀU
"""
function qn_requirements_test(H, U, V)
    H_test  = (H ≈ H')
    UV_test = (U'V ≈ V'U)
    
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
    
When H⁻¹ is approximating a positive-definite Hessian A, it is expected
that H converges to A⁻¹ when repeatedly updating H with curvature information
obtained from sampling ∇²f randomly generated directions. We use orthogonal
directions to update H with new information. 

Before each update a qn_requirements_test is performed.
After each update a qn_secant_test is performed. 
"""
function qn_convergence_test(QN::Function, test::QNTest; max_itr=10000, tol = 1.0e-8)
	A, Ainv, H, U, V, δ = test.A, test.Ainv, test.H, test.U, test.V, test.δ

    Ainv_norm = norm(Ainv)

    i, error = 0, norm(Ainv - H)/Ainv_norm

	@printf "    Update: Hₖ = %s(Hₖ₋₁, U, V, δ)\n" QN
	@printf "          Initial |A⁻¹ - H| = %1.5e\n" error

	while error > tol
        # test
        H_test, UV_test = qn_requirements_test(H, U, V)
        !H_test      && @printf "Violation at i = %d: ||H   -  Hᵀ||   = %1.4e\n" i norm(H - H') 
        !UV_test     && @printf "Violation at i = %d: ||UᵀV - VᵀU||   = %1.4e\n" i norm(U'V - V'U)


        H = QN(H, U, V, δ)

        secant_test = qn_secant_test(H, U, V)
        error = norm(Ainv - H)/Ainv_norm


        !secant_test && @printf "Violation at i = %d: ||HnewV - U||  = %1.4e\n" i norm(H*V - U)

     
        U = orth(V - U*(U' * V))
        V = A*U
        (i+=1) > max_itr && break
	end

    pass = (error < tol ? true : false)
	@printf "          Final   |A⁻¹ - H| = %1.5e\n" error
	@printf "    %s: Hₖ %s A⁻¹ in %d iterations\n" (pass ? "SUCCESS" : "FAILURE") (pass ? "→" : "↛" ) i
	@printf "    ----------------------------------------\n"
	return error ≤ tol
end


function run_tests()
    n, w, name = 10, 1, "QNTest"
	TS = [QNTest(name = name, n = n, w = w),  QNTest(name = name, n = n, w = w)]

	for test ∈ TS
        @printf "\n    %s: n = %d, w = %d\n" test.name test.n test.w
        @printf "    ----------------------------------------\n"
		qn_convergence_test(bSR1, test)
		qn_convergence_test(bPSB, test, max_itr=100000)
	end
    return TS
end

# @testset "qn_convergence_test" begin
#     n, w, name = 10, 3, "QN convergence to ill-condition SPD A"
# 	TS = [QNTest(name = name, n = n, w = w, noise = 0.1),  QNDriver(name = name, n = n, w = w, noise = 1.0)]
# 	for test ∈ TS
# 		@test qn_convergence_test(BFGS, test)
# 		@test qn_convergence_test(SR1, test)
# 	end
# end