function optimize(f::Function, ∇f::Function, x₀::AbstractArray{<:Real}, driver=nothing)

    d = (isa(driver, Nothing) ? Driver(n=length(x0)) : driver)

    QN, Sₖ_update, ϵ, δ, Δₘ = d.QN, d.Sₖ_update, d.ϵ, d.δ, d.Δₘ

    xₖ, Sₖ = x₀, d.S₀ 

    fₖ = f(xₖ)

    gₖ, hₖ, Yₖ = gHS(∇f, xₖ, Sₖ) 

    Hₖ = QN(d.H₀, [Sₖ gₖ], [Yₖ hₖ], δ)

    Qₖ = [hₖ gₖ Yₖ]

    gₖ_norm = norm(gₖ)

    Δₖ = 0.1*gₖ_norm

    P, b, C = trs_model(Qₖ, Hₖ, gₖ)

    result = Result(d, xₖ, fₖ, gₖ_norm, Δₖ)

    while gₖ_norm > ϵ
        (result.k+=1) ≥ d.max_iter && break

        aₖ, _ = trs_small(P, b, Δₖ, C; compute_local=false)

        aₖ = vec(aₖ)   

        pₖ = Hₖ * Qₖ * aₖ

        pₖ_norm = norm(pₖ)

        xₜ = xₖ + pₖ      

        fₜ = f(xₜ)  

        Qₖaₖ = Qₖ * aₖ

        ared = (fₖ - fₜ)

        pred = 0 - (0.5*dot(Qₖaₖ, Hₖ, Qₖaₖ) + (Hₖ * gₖ)' * Qₖaₖ)

        @assert pred ≥ 0

        ρ = ared / pred

        if ρ > 0
            xₖ = xₜ

            fₖ = fₜ

            Sₖ = Sₖ_update(Sₖ, Yₖ)

            gₖ, hₖ, Yₖ = gHS(∇f, xₖ, Sₖ) 

            Hₖ = QN(Hₖ, [Sₖ gₖ], [Yₖ hₖ], δ)

            Qₖ = [hₖ gₖ Yₖ]

            gₖ_norm = norm(gₖ)

            P, b, C = trs_model(Qₖ, Hₖ, gₖ)

            obs!(result, fₖ, gₖ_norm, Δₖ, ρ, pₖ_norm)
        end

        Δₖ = Δ_update(Δₖ, Δₘ, pₖ_norm, ρ) 
    end

    terminal_obs!(result, xₖ)
	
    return result
end

export optimize
