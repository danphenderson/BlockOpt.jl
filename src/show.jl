
function show_driver(io::IO, d::Driver)
    @printf io "\n%s %s Driver: n = %d, w = %d\n" d.name d.QN d.n d.w
    @printf io "-----------------------------------------------------------\n"
    @printf io "  Hessian Samples: %d\n" 2*d.w
    @printf io "  Terminal Conditions: ||∇fₖ|| < %1.2e or %d iterations\n\n" d.ϵ d.max_iter
    return nothing
end

function Base.show(io::IO, m::Result)
    show_driver(io, m.d)

    pass = (m.d.ϵ ≥ last(m.g_norms) ?  true : false)
    @printf io "%s %s Iteration Observations:\n" m.d.name m.d.QN
    @printf io "-----------------------------------------------------------\n"
    @printf io "  %s" (pass ? "SUCCESS" : "FAIL")
    @printf io "  %1.2e %s %1.4e" last(m.g_norms) (pass ? "≤" : "≰") m.d.ϵ
    @printf io "  in %d steps\n"  (length(m.g_norms)-1)
    @printf io "  gAD Evaluations: %d\n\n" m.cost
    @printf io "  f(x₀)  = %1.4e\n"   first(m.f_vals)
    @printf io "  ∇f(x₀) = %1.4e\n\n" first(m.g_norms)
    @printf io "  Terminal Iteration: k = %d\n" m.k
    @printf io "  f(xₖ)  = %1.4e\n"    last(m.f_vals)
    @printf io "  ∇f(xₖ) = %1.4e\n\n"  last(m.g_norms) 
    @printf io "  Minimum Δ:     %1.4e\n" minimum(m.Δ_vals)
    @printf io "  Minimum Step:  %1.4e\n" minimum(m.p_vals)
end

@userplot ObjTrace
@recipe function f(result::ObjTrace)
    xlabel := "Steps Taken"
    title  --> "$(result.args[1].d.name) (n = $(result.args[1].d.n))"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            push!(x, result.args[i].f_vals)
            labels[1,i] = "\$\\mathrm{$(result.args[i].d.QN) } ~ w = \\mathrm{$(result.args[i].d.w)} ~ f_k\$"
        end
        label --> labels
        x
    end
end

@userplot GradTrace
@recipe function f(result::GradTrace)
    xlabel --> "Steps Taken"
    title  --> "$(result.args[1].d.name) (n = $(result.args[1].d.n))"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            push!(x, result.args[i].g_norms)
            labels[1,i] = "\$\\mathrm{$(result.args[i].d.QN) } ~ w = \\mathrm{$(result.args[i].d.w)} ~ \\nabla f_k\$"
        end
        label --> labels
        x
    end
end

@userplot RadiusTrace
@recipe function f(result::RadiusTrace)
    xlabel --> "Steps Taken"
    title  --> "$(result.args[1].d.name) (n = $(result.args[1].d.n))"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            push!(x, result.args[i].Δ_vals)
            labels[1,i] = "\$\\mathrm{$(result.args[i].d.QN) } ~ w = \\mathrm{$(result.args[i].d.w)} ~ \\Delta_k\$"
        end
        label --> labels
        x
    end
end

@userplot StepTrace
@recipe function f(result::StepTrace)
    xlabel --> "Steps Taken"
    title  --> "$(result.args[1].d.name) (n = $(result.args[1].d.n))"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            push!(x, result.args[i].p_vals)
            labels[1,i] = "\$\\mathrm{$(result.args[i].d.QN) } ~ w = \\mathrm{$(result.args[i].d.w)} ~ ||p_k||\$"
        end
        label --> labels
        x
    end
end

@userplot RhoTrace
@recipe function f(result::StepTrace)
    xlabel --> "Steps Taken"
    title  --> "$(result.args[1].d.name) (n = $(result.args[1].d.n))"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            push!(x, result.args[i].ρ_vals)
            labels[1,i] = "\$\\mathrm{$(result.args[i].d.QN) } ~ w = \\mathrm{$(result.args[i].d.w)} ~ ||p_k||\$"
        end
        label --> labels
        x
    end
end

export rhotrace, rhotrace!, steptrace, steptrace!, radiustrace, radiustrace!, objtrace, objtrace!, gradtrace, gradtrace!