const NAME         = "TestDir"
const test_model   = Model(NAME);
const n            = 10
const λs           = sort(n*rand(n))
const ∇²f          = Symmetric(begin Q = orth(randn(n, n)); Q'*diagm(λs)*Q end)
const ∇²f⁻¹        = inv(∇²f) 
const f            = x -> 0.5*x'∇²f*x
const LaTex        = "\$\\frac{1}{2} x^\\Top \\nabla^2 f x\$"
const ∇f!          = (g, x) -> (g .= ∇²f*x)
const x₀           = randn(n)
const f₀           = f(x₀)
const ∇f₀          = ∇f!(similar(x₀), x₀)
const ∇f₀_norm     = norm(∇f₀) 
const h₀           = ∇²f*∇f₀
const test_options = DriverOptions();
const test_driver  = Driver(options=test_options);
const Δₘ           = 100.0
const δ            = 1.0e-12
const ϵ            = 10.0e-6
const w            = 3
const N            = 2000
const WEAVE_LEVEL  = ALL
const LOG_LEVEL    = INFO
const S_UPDATE     = S_update_c 
const QN_UPDATE    = SR1
const PFLAG        = false


function restricted_type_test(type)
    @test_throws AccessError type.afield

    @test propertynames(type) ≡ ()

    return nothing
end


# TODO: Define memory manipulation test here


function rosenbrock_model(n::Int) 
    rosen_model = Model("rosenbrock")

    objective!(rosen_model, 
        x -> begin
            N = lastindex(x)
            return 100sum((x[i+1] - x[i]^2)^2 for i = 1:N-1) + sum((x[i] - 1)^2 for i = 1:N-1)
        end
    )

    gradient!(rosen_model, 
        (g, x) -> begin
            N = lastindex(x)
            g[1] = -2*(1 - x[1]) - 400*x[1]*(-x[1]^2 + x[2])
            for i in 2:N-1
                g[i] = -2*(1 - x[i]) + 200*(-x[i-1]^2 + x[i]) - 400*x[i]*(-x[i]^2 + x[1 + i])
            end
            g[N] = 200 * (x[N] - x[N-1]^2)
            return g
        end
    )

    initial_iterate!(rosen_model, randn(100))

    return rosen_model
end

# function rosen(x)
#    N = lastindex(x)
#    return 100sum((x[i+1] - x[i]^2)^2 for i = 1:N-1) + sum((x[i] - 1)^2 for i = 1:N-1) 
# end

# function ∇rosen!(g, x)
#     N = lastindex(x)
#     g[1] = -2*(1 - x[1]) - 400*x[1]*(-x[1]^2 + x[2])
#     for i in 2:N-1
#         g[i] = -2*(1 - x[i]) + 200*(-x[i-1]^2 + x[i]) - 400*x[i]*(-x[i]^2 + x[1 + i])
#     end
#     g[N] = 200 * (x[N] - x[N-1]^2)
#     return g
# end