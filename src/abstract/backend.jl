export AbstractBackend
export blockBFGS, blockPSB, blockSR1
export S_update_a, S_update_b, S_update_c, S_update_d, S_update_e, S_update_f, solve!

"""
    AbstractBackend <: AbstractBlockOptType

The abstract base type of a simulation backend.

The interface contract is minimal leaving flexibility in specifying the
iterations memory representation. The contract requires accessors which
specify numerical experiment options under focus.

# Implement:
    trace
    gradAD
    gradHS
    blockBFGS
    blockSR1
    blockPSB
    S_update_a
    S_update_b
    S_update_c
    S_update_d
    S_update_e
    S_update_f

See also: `AbstractSimulation`.
"""
abstract type AbstractBackend{T<:Real, S<:AbstractArray} <: AbstractBlockOptType end


"""
trace(b::AbstractBackend)
"""
trace(b::AbstractBackend) = @contract AbstractBackend :trace


"""
blockBFGS(b::AbstractBackend)

# in docs/tutorials.*.md show issues of definite updates

See: ``Algorithm 4.1.``
"""
blockBFGS(b::AbstractBackend) = @contract AbstractBackend :blockBFGS


"""
blockSR1(b::AbstractBackend)

Returns the algebraically mininimal SR1 inverse Quasi-Newton block update satisfying the
inverse multi-secant condition ``H ⋅ V = U ``, where δ is the Moore-Penrose psuedoinverse
relative tolerance. 

See: ``Algorithm 4.2.``
"""
blockSR1(b::AbstractBackend) = @contract AbstractBackend :blockSR1


"""
blockPSB(b::AbstractBackend)

Powell-Symmetric-Broyden generalized Quasi-Newton block update,
where δ is the Moore-Penrose psuedoinverse relative tolerance. 

See: ``Algorithm 4.3.``
"""
blockPSB(b::AbstractBackend) = @contract AbstractBackend :blockPSB


"""
S_update_a(b::AbstractBackend)

See: Equation ``(6.1a)``.
"""
S_update_a(b::AbstractBackend) = @contract AbstractBackend :S_update_a


"""
S_update_b(b::AbstractBackend)

See: Equation ``(6.1b)``.
"""
S_update_b(b::AbstractBackend) = @contract AbstractBackend :S_update_b


"""
S_update_c(b::AbstractBackend)

See: Equation ``(6.1c)``.
"""
S_update_c(b::AbstractBackend) = @contract AbstractBackend :S_update_c


"""
S_update_d(b::AbstractBackend)

See: Equation ``(6.1d)``.
"""
S_update_d(b::AbstractBackend) = @contract AbstractBackend :S_update_d


"""
S_update_e(b::AbstractBackend)

See: Equation ``(6.1e)``.
"""
S_update_e(b::AbstractBackend) = @contract AbstractBackend :S_update_e


"""
S_update_f(b::AbstractBackend)

See: Equation ``(6.1f)``.
"""
S_update_f(b::AbstractBackend) = @contract AbstractBackend :S_update_f


"""
solve!(b::AbstractBackend)

The driver of an AbstractBackend.

See: ``Algorithm 7.1.``
"""
solve!(b::AbstractBackend) = @contract AbstractBackend :solve!


trace_level(b::AbstractBackend) = trace_level(trace(b))


filename(b::AbstractBackend) = filename(trace(b))


io(b::AbstractBackend) = io(trace(b))



