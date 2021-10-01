function bSR1(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)
    U_minus_HV = U - H*V

    if size(U, 2) == 1
        return Symmetric(H + ((U_minus_HV)*(U_minus_HV)')/((U_minus_HV)'*V))
    end

    return Symmetric(H + U_minus_HV *  pinv(U_minus_HV'*V, rtol=δ) *  U_minus_HV')
end


function bPSB(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)
    if size(V, 2) == 1
        T₁ = 1/(V'*V)
    else 
        T₁ = pinv(V'*V, rtol=δ)
    end

    T₂ = V*T₁*(U - H*V)'
    return Symmetric(H + T₂ + T₂' - T₂ * V * T₁ * V')
end


function trs_model(Qₖ, Hₖ, gₖ)
    return Symmetric(Qₖ'*Hₖ*Qₖ), Qₖ'*Hₖ*gₖ, Symmetric(Qₖ'*Hₖ*Hₖ*Qₖ)
end


function Δ_update_optimal(Δₖ, Δₘ, pₖ_norm, ρ)
    η₁ = 0.0001
    η₂ = 0.99
    α₁ = 0.25
    α₂ = 3.5

    if ρ < η₁
        Δₖ = α₁*pₖ_norm
    elseif ρ ≥ η₂
        Δₖ = max(α₂*pₖ_norm, Δₖ)
    end

    return Δₖ
end

function orth(S::AbstractArray{<:Real})
    return Matrix(qr(S).Q)
end

function Δ_update(Δₖ, Δₘ, pₖ_norm, ρ)
    if ρ < 0.25
        Δₖ = max(0.25*Δₖ, 1.0e-9)
    elseif ρ > 0.75 && pₖ_norm ≈ Δₖ
        Δₖ = min(2*Δₖ, Δₘ)
    end

    return Δₖ
end


function Sₖ_update_a(Sₖ, Yₖ, pₖ)
    return orth(randn(size(Sₖ, 1), size(Sₖ, 2)))
end


function Sₖ_update_b(Sₖ, Yₖ, pₖ)
    M = randn(size(Sₖ, 1), size(Sₖ, 2))
    return orth(M - Sₖ*(Sₖ' * M))
end


function Sₖ_update_c(Sₖ, Yₖ, pₖ)
    return orth(Yₖ - Sₖ*(Sₖ'*Yₖ))
end


function Sₖ_update_d(Sₖ, Yₖ, pₖ)
    return orth([ orth(randn(size(Sₖ, 1), size(Sₖ, 2)-1)) pₖ ])
end


function Sₖ_update_e(Sₖ, Yₖ, pₖ)
    M = randn(size(Sₖ, 1), size(Sₖ, 2)-1)
    return orth([orth(M - S*(S'*M)) pₖ])
end

function Sₖ_update_f(Sₖ, Yₖ, pₖ)
    return orth( [orth(Yₖ[:, end-1] - Sₖ*(Sₖ' * Yₖ[:, end-1])) pₖ])
end


function gAD(∇f!::Function, x::AbstractArray{<:Real}, S::AbstractArray{<:Real})
    Sdual = ForwardDiff.Dual{1}.(x,  eachcol(S)...)
    Ydual = ForwardDiff.Dual{1}.(zeros(length(x)),  eachcol(S)...)
    Ydual = ∇f!(Ydual, Sdual)

    g = similar(x)
    Y = similar(S)
    @views for i in 1:length(x)
        g[i]    = Ydual[i].value
        Y[i, :] = Ydual[i].partials[:]
    end

    return g, Y
end


function gHS(∇f!::Function, x::AbstractArray{<:Real}, S::AbstractArray{<:Real})
    w = Int((size(S, 2) + 1)/2) # end

    @assert 2w-1==size(S, 2)

    g, Y₁ = gAD(∇f!, x, S[:, 1:w])

    _, Y₂ = gAD(∇f!, x, [S[:, w+1:end] g])

    return g, Y₂[:, end], [Y₁ Y₂[:, 1:end-1]] # g, h, Y
end


export bSR1, bPSB, trs_small, gHS, gAD, orth, Sₖ_update_a, Sₖ_update_b, Sₖ_update_c, Sₖ_update_d, Sₖ_update_e, Sₖ_update_f, Δ_update, Δ_update_optimal, trs_model
