function optimize(f::Function, ∇f::Function, x₀::AbstractArray{<:Real}, driver=nothing)

    d = (isa(driver, Nothing) ? Driver(f=f, ∇f=∇f, x₀=x₀) : driver)

    n, QN, Sₖ_update, Δ_update, ϵ, δ, gₖ_norm, Δₘ, Δ₀ = d.n, d.QN, d.Sₖ_update, d.Δ_update, d.ϵ, d.δ, d.gₖ_norm, d.Δₘ, d.Δ₀

    xₖ, Sₖ = x₀, d.S₀ 

    fₖ = f(xₖ)

    gₖ, hₖ, Yₖ = gHS(∇f, xₖ, Sₖ) 

    α = 1/(sum(eigvals(Sₖ'*Yₖ))/n)

    Hₖ = QN(d.H₀*α, [Sₖ gₖ/gₖ_norm], [Yₖ hₖ/gₖ_norm], δ)

    Qₖ = [hₖ/gₖ_norm gₖ/gₖ_norm Yₖ]

    Δₖ = Δ₀

    P, b, C = trs_model(Qₖ, Hₖ, gₖ)

    result = Result(d, xₖ, fₖ, gₖ_norm, Δₖ)

    while gₖ_norm > ϵ && (result.k+=1) < d.max_iter

        aₖ, _ = trs_small(P, b, Δₖ, C, compute_local=false)

        aₖ = aₖ[:,1]

        pₖ = Hₖ * Qₖ * aₖ

        pₖ_norm = norm(pₖ)

        xₜ = xₖ + pₖ      

        fₜ = f(xₜ)  

        Qₖaₖ = Qₖ * aₖ

        ared = (fₖ - fₜ)

        pred = 0 - (0.5*dot(Qₖaₖ, Hₖ, Qₖaₖ) + (Hₖ * gₖ)' * Qₖaₖ)

        ρ = ared / pred

        if ared > 0.0
            xₖ = xₜ

            fₖ = fₜ

            Sₖ = Sₖ_update(Sₖ, Yₖ)

            gₖ, hₖ, Yₖ = gHS(∇f, xₖ, Sₖ) 

            gₖ_norm = norm(gₖ)

            Hₖ = QN(Hₖ, [Sₖ gₖ/gₖ_norm], [Yₖ hₖ/gₖ_norm], δ)

            Qₖ = [hₖ/gₖ_norm gₖ/gₖ_norm Yₖ]

            P, b, C = trs_model(Qₖ, Hₖ, gₖ)

            obs!(result, fₖ, gₖ_norm, Δₖ, ρ, pₖ_norm)
        end

        Δₖ = Δ_update(Δₖ, Δₘ, pₖ_norm, ρ) 
    end

    terminal_obs!(result, xₖ)
	
    return result
end

export optimize
