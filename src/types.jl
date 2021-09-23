
Base.@kwdef struct Driver
    n::Int
    w::Int        = 3
    name::String  = ""
    ϵ::Float64    = 10.0e-7
    δ::Float64    = 1.0e-12
    Δₘ::Float64   = 1.0
    max_iter::Int = 1000
    QN::Function  = bSR1
    Sₖ_update::Function = Sₖ_update_std 	
    S₀::AbstractArray{<:Real} = orth(rand(n, 2w-1))
    H₀::AbstractArray{<:Real} = (zeros(n,n) + I)
end

mutable struct Result
    d::Driver
    x_term::AbstractArray{<:Real}  
    f_vals::AbstractArray{<:Real}
    g_norms::AbstractArray{<:Real}
    Δ_vals::AbstractArray{<:Real}

    ρ_vals::AbstractArray{<:Real}
    p_vals::AbstractArray{<:Real}
    cost::Int
    k::Int
    
    function Result(d, x₀, f₀, g₀_norm, Δ₀)
    	new(d, similar(x₀), [f₀], [g₀_norm], [Δ₀], Vector{Float64}(), Vector{Float64}(), 2, 0)
    end
end

function obs!(res::Result, fₖ, gₖ_norm, Δₖ, ρ, pₖ)
    push!(res.f_vals, fₖ)
    push!(res.g_norms, gₖ_norm)
    push!(res.Δ_vals, Δₖ)
    push!(res.ρ_vals, ρ)
    push!(res.p_vals, pₖ)
    res.cost += 2
    return nothing
end

function terminal_obs!(res::Result, x_star)
    res.x_star = x_star
end

export Driver, Result