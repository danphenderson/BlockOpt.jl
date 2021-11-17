orth(S::AbstractArray{<:Real}) = Matrix(qr(S).Q)


"""
    S_update_a

Random set of orthonormal sample directions. 

See: Equation (6.1.a).
"""
function S_update_a(Sₖ, Yₖ, pₖ) 
    return orth(randn(eltype(Sₖ), size(Sₖ)...))
end


"""
    S_update_b

Random set of sample directions orthogonal to the pervious sample space given by input Sₖ.

See: Equation (6.1.b).
"""
function S_update_b(Sₖ, Yₖ, pₖ) 
    M = randn(eltype(Sₖ), size(Sₖ)...)
    return orth(M - Sₖ*(Sₖ' * M))
end


"""
    S_update_c

Attempts to guide algorithm to accurately resolve eigen-space associated with the larger
Hessian eigenvalues.

See: Equation (6.1.c).
"""
function S_update_c(Sₖ, Yₖ, pₖ)
    return orth(Yₖ - Sₖ*(Sₖ'*Yₖ))
end


"""
    S_update_d

Variant of (6.1.a) that includes approximate curvature information along the previously
choosen step. 

See: Equation (6.1.d).
"""
function S_update_d(Sₖ, Yₖ, pₖ)
    return orth([ orth(randn(eltype(Sₖ), size(Sₖ, 1), size(Sₖ, 2)-1)) pₖ ])
end


"""
    S_update_e

Variant of (6.1b) that includes approximate curvature information along the previously
choosen step. 

See: Equation (6.1.e).
"""
function S_update_e(Sₖ, Yₖ, pₖ) 
    M = randn(size(Sₖ, 1), size(Sₖ, 2)-1)
    return orth([orth(M - Sₖ*(Sₖ'*M)) pₖ])
end


"""
    S_update_f

Variant of (6.1c) that includes approximate curvature information along the previously
choosen step. 

See: Equation (6.1.f).
"""
function S_update_f(Sₖ, Yₖ, pₖ)
    return orth([ orth(Yₖ[:, begin:end-1] - Sₖ*(Sₖ' * Yₖ[:, begin:end-1])) pₖ ])
end


"""
    SR1

Returns the algebraically mininimal SR1 inverse Quasi-Newton block update satisfying the
inverse multi-secant condition ``H ⋅ V = U ``, where δ is the Moore-Penrose psuedoinverse
relative tolerance. 

See: Algorithm ``4.2.``
"""
function SR1(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)
    U_minus_HV = U - H*V

    if size(U, 2) == 1
        return Symmetric(H + ((U_minus_HV)*(U_minus_HV)')/((U_minus_HV)'*V))
    end

    return Symmetric(H + U_minus_HV *  pinv(U_minus_HV'*V, rtol=δ) *  U_minus_HV')
end


"""
    PSB

Powell-Symmetric-Broyden generalized Quasi-Newton block update,
where ``δ`` is the Moore-Penrose psuedoinverse relative tolerance. 

See: Algorithm ``4.3.``
"""
function PSB(H::AbstractArray{<:Real}, U::AbstractArray{<:Real}, V::AbstractArray{<:Real}, δ::Float64)
    if size(V, 2) == 1
        T₁ = 1/(V'*V)
    else 
        T₁ = pinv(V'*V, rtol=δ)
    end

    T₂ = V*T₁*(U - H*V)'
    return Symmetric(H + T₂ + T₂' - T₂ * V * T₁ * V')
end


"""
Driver

Specifies the driving parameters of a `Simulation` instance.
A driver is assigned an immutable `S_update`, `QN_update`, and `pflag` upon
construction, either by keyword arguments or fallback to the default values.

See `S_update`, `QN_update`, and `pflag` for more on keyword argument options.
"""
struct Driver
    S_update::Function
    QN_update::Function
    pflag::Bool
    options::DriverOptions

    function Driver(;S_update=S_update_c, QN_update=SR1, pflag=false, options=DriverOptions())
        # TODO: Confrim S_update and QN_update inputs are valid
        #       Maybe parse symbol and compare to set of strings?
        new(S_update, QN_update, pflag, options)
    end
end


"""
    S_update(d::Driver) 

The supplemental sample direction update formula of Driver `d`.

Options: `S_update`, `S_update_a`, `S_update_b`, `S_update_c`, `S_update_d`, `S_update_e`, `S_update_f`
"""
S_update(d::Driver) = getfield(d, :S_update)


"""
    QN_update(d::Driver)

The QN update formula of Driver `d`.

Options: `SR1`, `PSB`
"""
QN_update(d::Driver) = getfield(d, :QN_update)


"""
    pflag(d::Driver)

The preliminary secant QN update flag of driver `d` wraping a boolean.

Options `true`, `false`
"""
pflag(d::Driver) = getfield(d, :pflag)


options(d::Driver) = getfield(d, :options)


# Inhereted/Forwarded DriverOptions Methods
samples(d::Driver) = samples(options(d))


samples!(d::Driver, samples) = samples!(options(d), samples)


Δ_max(d::Driver) = Δ_max(options(d))


Δ_max!(d::Driver, Δ_max) = Δ_max!(options(d), Δ_max)


δ_tol(d::Driver) = δ_tol(options(d))


δ_tol!(d::Driver, δ_tol) = δ_tol!(options(d), δ_tol)


ϵ_tol(d::Driver) = ϵ_tol(options(d))


ϵ_tol!(d::Driver, ϵ_tol) = ϵ_tol!(options(d), ϵ_tol)


max_iterations(d::Driver) =  max_iterations(options(d))


max_iterations!(d::Driver, m) = max_iterations!(options(d), m)


weave_level(d::Driver) = weave_level(options(d))


weave_level!(d::Driver, level) = weave_level!(options(d), level)


log_level(d::Driver) = log_level(options(d))


log_level!(d::Driver, level) =  log_level!(options(d), level)


Base.getproperty(d::Driver, s::Symbol) = @restrict Driver


Base.propertynames(d::Driver) = ()