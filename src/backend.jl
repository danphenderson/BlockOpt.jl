"""
trs_model(Qₖ, Hₖ, gₖ)
"""
function trs_model(Qₖ, Hₖ, gₖ)
    return Symmetric(Qₖ'*Hₖ*Qₖ), Qₖ'*Hₖ*gₖ, Symmetric(Qₖ'*Hₖ*Hₖ*Qₖ)
end


"""
gradHS(b::AbstractBackend)

Makes two sequential calls to `gradAD`, generating second-order
information for `2w-1` sampling directions about a point ``x``,
including the steepest descent direction.

# Definition
For an objective function ``f`` mapping ``ℜⁿ → ℜ``,  
```math
    g, h, Y ⟵ gradHS(x, S) , \\text{ such that }

        x ∈ ℜⁿˣ¹ 
        S ∈ ℜⁿˣ²ʷ
        g = ∇f(x) ∈ ℜⁿˣ¹
        h = ∇²f(x) ⋅ g ∈ ℜⁿˣ¹
        Y = ∇²f(x) ⋅ S ∈ ℜⁿˣ²ʷ.
```

See: Algorithm 3.1.
"""
function gradHS_init(∇f!, x, S)
    w = Int((size(S, 2) + 1)/2) # end

    @assert 2w-1==size(S, 2)

    g, Y₁ = gAD(∇f!, x, S[:, 1:w])

    _, Y₂ = gAD(∇f!, x, [S[:, w+1:end] g])

    return g, Y₂[:, end], [Y₁ Y₂[:, 1:end-1]] # g, h, Y
end 


function alloc_memory(f, ∇f!, x₀, QN_update, S_update, n, w)
    args = []
    xₖ = xₒ
    fₖ = f(xₖ)
    Sₖ = orth(randn(n, 2w - 1))
    gₖ, hₖ, Yₖ = gradHS(xₖ) 
    Uₖ, Vₖ = UV_build(gₖ, hₖ, Yₖ)
    Hₖ = QN_update(H_init(n, w), Uₖ, Vₖ)
    P, b, C  = trs_model(Qₖ, Hₖ, gₖ)
    return 
end


"""
Backend <: AbstractBackend
"""
struct Backend{T, S} <: AbstractBackend{T, S}
    f::Function
    ∇f!::Function
    x₀::S
    options::DriverOptions
    record::ModelRecord
    QN_update::Symbol
    S_update::Symbol
    Trace::BlockOptTrace


    # bits types copied from options
    Δₘ
    ϵ
    δ

    # memory state representation
    fₖ
    gₖ
    hₖ
    Sₖ
    Yₖ
    Uₖ
    Vₖ
    P
    b
    C


    function Backend{T, S}(
        f::Function,
        ∇f!::Function,
        x₀::S,
        options::DriverOptions,
        record::ModelRecord,
        QN_update = :blockSR1,
        S_update = :S_update_d
    ) where {T, S}
        
        memory = alloc_memory(f, ∇f!, x₀, QN_update, S_update, length(xₒ), samples(options))
        new{T,S}(f, ∇f!, x₀, options, record, QN_update, S_update, Trace(), memory...)
    end
end



"""
    BlockOptBackend
"""
Backend(
    f::Function, 
    ∇f!::Function,
    x₀::S,
    options::DriverOptions, 
    record::ModelRecord,
    QN_update=:blockSR1,
    S_update=:S_update_d
) where {S} = Backend{eltype(S), S}(f, ∇f!, x₀, options, record, QN_update, S_update)


"""
gradAD(b::Backend)

Generates accurate secord-order curvature information for a block
of ``w`` sampling directions about a point ``x``.

# Definition
For an objective function``f`` mapping ``ℜⁿ → ℜ``,  
```math
    g, Y₁ ⟵ gradAD(x, S₁) , \\text{ such that }
        x ∈ ℜⁿˣ¹ 
        S ∈ ℜⁿˣʷ
        g = ∇f(x) ∈ ℜⁿˣ¹
        Y = ∇²f(x) ⋅ S ∈ ℜⁿˣʷ.
```

See: Section 3, proceeding Algorithm 3.1.
"""
function gradAD(b::Backend)
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


"""
gradHS gradHS(b::Backend)

Makes two sequential calls to `gradAD`, generating second-order
information for `2w-1` sampling directions about a point ``x``,
including the steepest descent direction.

# Definition
For an objective function ``f`` mapping ``ℜⁿ → ℜ``,  
```math
    g, h, Y ⟵ gradHS(x, S) , \\text{ such that }

        x ∈ ℜⁿˣ¹ 
        S ∈ ℜⁿˣ²ʷ
        g = ∇f(x) ∈ ℜⁿˣ¹
        h = ∇²f(x) ⋅ g ∈ ℜⁿˣ¹
        Y = ∇²f(x) ⋅ S ∈ ℜⁿˣ²ʷ.
```

See: Algorithm 3.1.
"""
function gradHS(b::Backend)
    w = Int((size(S, 2) + 1)/2) # end

    @assert 2w-1==size(S, 2)

    g, Y₁ = gAD(∇f!, x, S[:, 1:w])

    _, Y₂ = gAD(∇f!, x, [S[:, w+1:end] g])

    return g, Y₂[:, end], [Y₁ Y₂[:, 1:end-1]] # g, h, Y
end #gAD(∇f!::Function, x::AbstractArray{<:Real}, S::AbstractArray{<:Real})


"""
Δ_update(b::AbstractBackend)
"""
function Δ_update(b::Backend)
    if ρ < 0.25
        Δₖ = max(0.25*Δₖ, 1.0e-9)
    elseif ρ > 0.75 && pₖ_norm ≈ Δₖ
        Δₖ = min(2*Δₖ, Δₘ)
    end

    return Δₖ
end # Δ_update(Δₖ, Δₘ, pₖ_norm, ρ)


"""
orth(b::AbstractBackend)
"""
function orth(b::Backend)
    return Matrix(qr(S).Q)
end # orth(S::AbstractArray{<:Real})


function blockSR1(b::Backend)
    U_minus_HV = U - H*V

    if size(U, 2) == 1
        return Symmetric(H + ((U_minus_HV)*(U_minus_HV)')/((U_minus_HV)'*V))
    end

    return Symmetric(H + U_minus_HV *  pinv(U_minus_HV'*V, rtol=δ) *  U_minus_HV')
end # blockSR1(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)



function blockPSB(b::Backend)
    if size(V, 2) == 1
        T₁ = 1/(V'*V)
    else 
        T₁ = pinv(V'*V, rtol=δ)
    end

    T₂ = V*T₁*(U - H*V)'
    return Symmetric(H + T₂ + T₂' - T₂ * V * T₁ * V')
end # blockPSB(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)



function S_update_a(b::Backend)
    return orth(randn(size(Sₖ, 1), size(Sₖ, 2)))
end


function S_update_b(b::Backend)
    M = randn(size(Sₖ, 1), size(Sₖ, 2))
    return orth(M - Sₖ*(Sₖ' * M))
end


function S_update_c(b::Backend)
    return orth(Yₖ - Sₖ*(Sₖ'*Yₖ))
end



function S_update_d(b::Backend)
    return orth([ orth(randn(size(Sₖ, 1), size(Sₖ, 2)-1)) pₖ ])
end



function S_update_e(b::Backend)
    M = randn(size(Sₖ, 1), size(Sₖ, 2)-1)
    return orth([orth(M - S*(S'*M)) pₖ])
end



function S_update_f(b::Backend)
    return orth( [orth(Yₖ[:, end-1] - Sₖ*(Sₖ' * Yₖ[:, end-1])) pₖ])
end



function solve!(b::Backend)
    initialize 

    trs_model(b) 
    trs_small(b)

    trs_trial(b)


    if trial_accepted(b)

        if plfag

        end
        QN 
        gradHS



    end 
end