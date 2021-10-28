

mutable struct BlockOptCPUMemory{T<:AbstractFloat, S<:Vector}
    n::Int
    w::Int
    f::Function 
    ∇f!::Function
    QN_update::Symbol
    S_update::Symbol
    pflag::Bool
    Δₘ::Float64
    δ::Float64
    ϵ::Float64
    max_iterations::Int
    xₖ::S
    fₖ::T
    gₖ::S
    hₖ::S
    Δₖ::T 
    Uₖ::S
    Vₖ::S
    Hₖ::S
    Qₖ::S
    P::Symmetric
    b::S
    C::Symmetric
    pₖ::S
    aₖ::S
    xₜ::S 
    fₜ::T
    ρ::T

    function BlockOptCPUMemory{T, S}(m::Model{T, S}, d::Driver) where {T, S}
        n, w   = dimension(m), samples(d)/2

        f, ∇f! = x -> objective(m)(x), (g, x) -> gradient(m)(g, x)

        QN_update, S_update, pflag, N = QN_update(d), S_update(d), pflag(d), max_iterations(d)

        ϵ, δ, Δₘ, Δₖ   = ϵ_tol(d), δ_tol(d), Δ_max(d), 0.0

        xₖ = copy(initial_iterate(m))

        fₖ, gₖ_norm = f(xₖ), zero(T)

        Uₖ = orth(randn(T, n, 2w - 1))

        Vₖ = similar(Uₖ)

        Hₖ = zeros(T, n, n) + I

        Qₖ = zeros(T, n, 2w+1)

        P = Symmetric(zeros(T, n, 2w+1))

        b = zeros(T, n)

        C = similar(P)

        pₖ = similar(xₖ)

        aₖ = zeros(T, 2w+1)

        fₜ, xₜ = zero(T), similar(xₖ)

        ρ = zero(T)
        
        new{T, S}(
            n,
            w, 
            f,
            ∇f!,
            QN_update,
            S_update,
            pflag,
            N,
            ϵ,
            δ,
            Δₘ,
            Δₖ,
            xₖ,
            fₖ,
            gₖ_norm, 
            Uₖ,
            Vₖ,
            Hₖ,
            Qₖ,
            P,
            b,
            C,
            pₖ,
            aₖ,
            fₜ,
            xₜ,
            ρ
        )
    end
end


function blockSR1(mem::BlockOptCPUMemory)
    U_minus_HV = mem.Uₖ - mem.Hₖ*mem.Vₖ
    if size(mem.Uₖ, 2) == 1
        return Symmetric(mem.Hₖ + ((U_minus_HV)*(U_minus_HV)')/((U_minus_HV)'*mem.Vₖ))
    end
    return Symmetric(mem.Hₖ + U_minus_HV *  pinv(U_minus_HV'*mem.Vₖ, rtol=δ) *  U_minus_HV')
end 


function blockPSB(mem::BlockOptCPUMemory)
    if size(mem.Vₖ, 2) == 1
        T₁ = 1/(mem.Vₖ'*mem.Vₖ)
    else 
        T₁ = pinv(mem.Vₖ'*mem.Vₖ, rtol=δ)
    end
    T₂ = mem.Vₖ*T₁*(mem.Uₖ - mem.Hₖ*mem.Vₖ)'
    return Symmetric(mem.Hₖ + T₂ + T₂' - T₂ * mem.Vₖ * T₁ * mem.Vₖ')
end 


function S_update_a(mem::BlockOptCPUMemory)
    return orth(randn(size(mem.Uₖ, 1), size(mem.Uₖ, 2)))
end 


function S_update_b(mem::BlockOptCPUMemory)
    M = randn(size(mem.Uₖ, 1), size(mem.Uₖ, 2))
    return orth(M - mem.Uₖ*(mem.Uₖ' * M))
end 


function S_update_c(mem::BlockOptCPUMemory)
    return orth(mem.Vₖ - mem.Uₖ*(mem.Uₖ'*mem.Vₖ))
end


# function S_update_d(mem::BlockOptCPUMemory)
#     return orth([ orth(randn(size(mem.Uₖ, 1), size(mem.Uₖ, 2)-1)) mem.pₖ])
# end


# function S_update_e(mem::BlockOptCPUMemory)
#     M = randn(size(Sₖ, 1), size(Sₖ, 2)-1)
#     return orth([orth(M - S*(S'*M)) pₖ])
# end


# function S_update_f(mem::BlockOptCPUMemory)
#     return orth( [orth(Yₖ[:, end-1] - Sₖ*(Sₖ' * Yₖ[:, end-1])) pₖ])
# end


function gradAD(mem, lo, hi) 
    Sdual = Dual{eltype(mem.x)}.(mem.x,  map(i -> view(mem.Uₖ, :, i), lo:hi)...)
    Ydual = Dual{eltype(mem.x)}.(mem.x,  map(i -> view(mem.Vₖ, :, i), lo:hi)...) 
    return value.(mem.∇f!(Ydual, Sdual))
end


function gradHS(mem::BlockOptCPUMemory)
    mem.Uₖ[:, end] = gAD(mem, 1, mem.w)
    gAD(mem, mem.w + 1, 2*mem.w)
    mem.gₖ_norm = norm(mem.Uₖ[:, end])
    mem.Uₖ[:, end] /=  mem.gₖ_norm
    mem.Vₖ[:, end] /=  mem.gₖ_norm
    return nothing
end


function trs_model(mem::BlockOptCPUMemory)
    mem.Qₖ = orth([mem.Vₖ[:, end] mem.Uₖ[:, end] mem.Vₖ[:, 1:end - 1]])
    mem.P = Symmetric(mem.Qₖ'*mem.Hₖ*mem.Qₖ)
    mem.b = mem.Qₖ'*mem.Hₖ*mem.gₖ
    mem.C = Symmetric(mem.Qₖ'*mem.Hₖ*mem.Hₖ*mem.Qₖ)
    return nothing
end

function trs_solve(mem::BlockOptCPUMemory)
    aₖ, _ = trs_small(mem.P, mem.b, mem.Δₖ, mem.C, compute_local=false)
    mem.aₖ = aₖ[:, 1]
    mem.pₖ = mem.Hₖ*mem.Qₖ*mem.aₖ
    return nothing
end


function trs_trial(mem::BlockOptCPUMemory)
    mem.xₜ = mem.xₖ + mem.pₖ
    mem.fₜ = mem.f(xₜ)
    Qₖaₖ = mem.Qₖ*mem.aₖ
    mem.ρ = (mem.fₖ - fₜ)/(0 - (0.5*dot(Qₖaₖ, mem.Hₖ, Qₖaₖ) + (mem.Hₖ * mem.Uₖ[:, end]*mem.gₖ_norm)' * Qₖaₖ))
    return nothing
end


function trial_accepted(mem::BlockOptCPUMemory)
    if mem.ρ > 0.0
        mem.xₖ = mem.xₜ
        mem.fₖ = mem.xₜ
        return true
    end
    return false
end


function Δ_update(mem::BlockOptCPUMemory)
    if ρ < 0.25
        Δₖ = max(0.25*Δₖ, 1.0e-9)
    elseif ρ > 0.75 && pₖ_norm ≈ Δₖ
        Δₖ = min(2*Δₖ, Δₘ)
    end
    return nothing
end 


function QN_update(mem::BlockOptCPUMemory)
    @eval $(mem.QN_update)(mem) 
    return nothing
end


function QN_secant(mem::BlockOptCPUMemory, s, y)
    @eval $(mem.QN_update)(mem.Hₖ, s, y, mem.δ) 
    return nothing
end


function S_update(mem::BlockOptCPUMemory)
    @eval $(mem.S_update)(mem)
    return nothing
end


function init(mem::BlockOptCPUMemory)
    gradHS(mem)
    α = mean(eigvals(mem.Uₖ[:, 1:end-1] * mem.Vₖ[:, 1:end-1]))
    mem.Δₖ = min(1.1*mem.gₖ_norm/(2*α), mem.Δₘ)
    mem.Hₖ = 1/α * mem.Hₖ
    return nothing
end