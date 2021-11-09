mutable struct BlockOptBackend 
    model::Model
    driver::Driver
    n::Int
    w::Int
    xₖ::Vector{Float64}

    # following fields storage is initilized in construction
    ∇fₖ::Vector{Float64}
    hₖ::Vector{Float64}
    pₖ::Vector{Float64}
    xₜ::Vector{Float64}
    fₖ::Float64
    fₜ::Float64
    ρ::Float64
    Δₖ::Float64
    ∇fₖ_norm::Float64
    pₖ_norm::Float64
    Sₖ::Matrix{Float64}
    Yₖ::Matrix{Float64}
    Uₖ::Matrix{Float64}
    Vₖ::Matrix{Float64}
    Hₖ::Symmetric{Float64, Matrix{Float64}}
    Qₖ::Matrix{Float64}
    P::Symmetric{Float64, Matrix{Float64}}
    b::Vector{Float64}
    C::Symmetric{Float64, Matrix{Float64}}
    aₖ::Vector{Float64}
    qₖ::Vector{Float64}
    

    function BlockOptBackend(m, d)
        # TODO: the driver & model must be locked from modifications
        # during simulation, or copy data. Look into a julia Mutex
        n, w = dimension(m), Int(samples(d)/2)

        xₖ = copy(initial_iterate(m))

        ∇fₖ = hₖ = pₖ = xₜ = qₖ = similar(xₖ)

        fₖ = fₜ = ρ = Δₖ = ∇fₖ_norm = pₖ_norm = 0.0

        Sₖ = orth(randn(n, 2w - 1))
 
        Yₖ = similar(Sₖ)

        Uₖ = zeros(n, 2w)

        Vₖ = similar(Uₖ)

        Hₖ = Symmetric(zeros(n, n) + I)

        Qₖ = zeros(n, 2w+1)

        P = Symmetric(zeros(2w+1 , 2w+1))

        b = zeros(2w+1)

        C = similar(P)

        aₖ = similar(b)

        new(
            m,
            d,
            n,
            w,
            xₖ,
            ∇fₖ,
            hₖ,
            pₖ,
            xₜ,
            fₖ,
            fₜ,
            ρ,
            Δₖ,
            ∇fₖ_norm,
            pₖ_norm,
            Sₖ,
            Yₖ, 
            Uₖ,
            Vₖ,
            Hₖ,
            Qₖ,
            P,
            b,
            C,
            aₖ,
            qₖ,
        )
    end
end


#Base.show(io::IO, b::BlockOptBackend) = return nothing

function Base.show(io::IO, b::BlockOptBackend)
    println(io, "BlockOptBackend:")
    println(io, "----------------------------------------")
    for field ∈ fieldnames(BlockOptBackend)
        println(io, "    $field:           $(show(getfield(b, field)))")
    end
    flush(io)
    return nothing
end


# Accessors used in simulation.jl to weave! (TODO: Restrict this class as well)
model(b::BlockOptBackend) = getfield(b, :model)


driver(b::BlockOptBackend) = getfield(b, :driver)


fₖ(b::BlockOptBackend) = getfield(b, :fₖ)


∇fₖ_norm(b::BlockOptBackend) = getfield(b, :∇fₖ_norm)


pₖ_norm(b::BlockOptBackend) = getfield(b, :pₖ_norm)


Δₖ(b::BlockOptBackend) = getfield(b, :Δₖ)


ρ(b::BlockOptBackend) = getfield(b, :ρ)


# Forward Needed Model Methods
obj(b::BlockOptBackend, x) = obj(model(b), x)


grad(b::BlockOptBackend, x) = grad(model(b), x)


grad!(b::BlockOptBackend, out, x) = grad!(model(b), out, x)


dimension(b::BlockOptBackend) = dimension(model(b))


# Forward Needed Driver/DriverOptions Methods
QN_update(b::BlockOptBackend) = QN_update(driver(b))


S_update(b::BlockOptBackend) = S_update(driver(b))


pflag(b::BlockOptBackend) = pflag(driver(b))


samples(b::BlockOptBackend) = samples(driver(b))


Δ_max(b::BlockOptBackend) = Δ_max(driver(b))


δ_tol(b::BlockOptBackend) = δ_tol(driver(b))


ϵ_tol(b::BlockOptBackend) = ϵ_tol(driver(b))


max_iterations(b::BlockOptBackend) = max_iterations(driver(b))


"""
terminal(b::BlockOptBackend, k::Int)

The number of trust-region subproblem solves is given by `k`.

## Development:
Remove BlockOptBackend terminal method for one manged in
simulation.jl. Alowing terminal access to trs_counter and
can observe other traced aspects (giving more state options).
"""
function terminal(b::BlockOptBackend, k::Int)

    if ∇fₖ_norm(b) ≤ ϵ_tol(b) || max_iterations(b) ≤ k
        return true
    end

    return false
end


function secantQN(b::BlockOptBackend)

    b.Hₖ = QN_update(b)(b.Hₖ, grad(b, b.xₜ) - b.∇fₖ, b.pₖ, δ_tol(b))

    return nothing
end


function blockQN(b::BlockOptBackend)

    b.Hₖ = QN_update(b)(b.Hₖ, b.Uₖ, b.Vₖ, δ_tol(b))

    return nothing
end


function update_Sₖ(b::BlockOptBackend)

    b.Sₖ = S_update(b)(b.Sₖ, b.Yₖ, b.pₖ)

    return nothing
end


function build_trs(b::BlockOptBackend)

    b.Qₖ = orth([b.hₖ/b.∇fₖ_norm  b.∇fₖ/b.∇fₖ_norm  b.Yₖ])

    b.P = Symmetric(b.Qₖ'*b.Hₖ*b.Qₖ)

    b.b = b.Qₖ'*b.Hₖ*b.∇fₖ

    b.C = Symmetric(b.Qₖ'*b.Hₖ*b.Hₖ*b.Qₖ)

    return nothing
end


function solve_trs(b::BlockOptBackend)

    aₖ, _ = trs_small(b.P, b.b, b.Δₖ, b.C, compute_local=false)

    b.aₖ = aₖ[:, 1]

    b.qₖ = b.Qₖ*b.aₖ

    b.pₖ = b.Hₖ*b.qₖ

    b.pₖ_norm = norm(b.pₖ)

    return nothing
end


function build_trial(b::BlockOptBackend)

    b.xₜ = b.xₖ + b.pₖ

    b.fₜ = obj(b, b.xₜ)

    b.ρ = (b.fₖ - b.fₜ)/(0 - (0.5*dot(b.qₖ, b.Hₖ, b.qₖ) + (b.Hₖ * b.∇fₖ)' * b.qₖ))

    return nothing
end


function update_Δₖ(b::BlockOptBackend)

    if 0.0 < b.ρ < 0.25
    
        b.Δₖ = 0.25*b.Δₖ
    
    elseif b.ρ > 0.75 && b.pₖ_norm ≈ b.Δₖ
    
        b.Δₖ = min(2*b.Δₖ, Δ_max(b))
    
    end

    return nothing
end


function accept_trial(b::BlockOptBackend)

    if b.ρ > 0

        b.xₖ = b.xₜ

        b.fₖ = b.fₜ

        return true
    end

    return false 
end


function gAD(b::BlockOptBackend, S) 
    
    Sdual = ForwardDiff.Dual{Float64}.(b.xₖ,  eachcol(S)...)
    
    Ydual = ForwardDiff.Dual{Float64}.(similar(b.xₖ),  eachcol(S)...)
    
    Ydual = grad!(b, Ydual, Sdual)
    
    g = similar(b.xₖ)
    
    Y = similar(S)
    
    @views for i in 1:length(g)
        g[i]    = Ydual[i].value
    
        Y[i, :] = Ydual[i].partials[:]
    end
    
    return g, Y
end


function build_UV(b::BlockOptBackend)
    
    b.Uₖ = [b.Sₖ b.∇fₖ / b.∇fₖ_norm] 
    
    b.Vₖ = [b.Yₖ b.hₖ  / b.∇fₖ_norm]
    
    return nothing
end


function gHS(b::BlockOptBackend)
    
    w = b.w
    
    g, Y₁ = gAD(b, b.Sₖ[:, 1:w])
    
    _, Y₂ = gAD(b, [b.Sₖ[:, w+1:end] g])
    
    b.∇fₖ_norm, b.∇fₖ, b.hₖ, b.Yₖ = norm(g), g, Y₂[:, end], [Y₁ Y₂[:, 1:end-1]]
    
    build_UV(b)
    
    return nothing
end


function initialize(b::BlockOptBackend)
    
    b.fₖ = obj(b, b.xₖ)
    
    gHS(b)
    
    α = mean(eigvals(b.Sₖ' * b.Yₖ))
    
    b.Δₖ = min(1.1*b.∇fₖ_norm/(2*α), Δ_max(b))
    
    b.Hₖ = 1/α * b.Hₖ
    
    blockQN(b)
    
    return nothing
end