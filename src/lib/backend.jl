"""
BlockOptBackend <: AbstractBackend
"""
struct BlockOptCPU <: AbstractBackend
    trace::BlockOptTrace
    memory::BlockOptCPUMemory

    function BlockOptCPU(memory, trace)
        new(trace, memory)
    end
end


function build_backend(model::Model{T, S}, driver::Driver) where {T, S}
    return BlockOptCPU(BlockOptCPUMemory{eltype(S), S}(model, driver), BlockOptTrace(model, driver))
end


orth(S) = Matrix(qr!(S).Q)


trace(b::BlockOptCPU) = getfield(m, :trace)


filename(b::BlockOptCPU) = filename(trace(m))


trace_level(b::BlockOptCPU) = level(trace(m))


io(b::BlockOptCPU) = io(trace(m))


memory(b::BlockOptCPU) = getfield(m, :memory)

"""
gradHS gradHS(b::BlockOptCPU)

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
function gradHS(b::BlockOptCPU)
    gradHS(memory(b))
end


"""
trs_model(b::BlockOptCPU)
"""
function trs_model(b::BlockOptCPU)
    trs_model(memory(b))
end


"""
trs_solve(b::BlockOptCPU)
"""
function trs_solve(b::BlockOptCPU)
    trs_solve(memory(b))
end


"""
trs_trial(b::AbstractBackend)
"""
function trs_trial(b::BlockOptCPU)
    trs_trial(memory(b))
end


function trial_accepted(b::BlockOptCPU)
    trial_accepted(memory(b))
end


"""
Δ_update(b::AbstractBackend)
"""
function Δ_update(b::BlockOptCPU)
    Δ_update(memory(b))
end


"""
QN(b::AbstractBackend)
"""
function QN(b::BlockOptCPU)
    QN(memory(b))
end


"""
optimize!(b::BlockOptCPU)
"""
function optimize!(b::BlockOptCPU)
    gradHS(b)

    trs_model(b) 

    trs_small(b)

    trs_trial(b)

    if trial_accepted(b)
        if plfag
            QN 
        end

        QN 

        gradHS
    end 
end