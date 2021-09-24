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
    @printf io "  in %d steps\n"                (length(m.g_norms)-1)
    @printf io "  gAD Evaluations: %d\n\n"      m.cost
    @printf io "  f(x₀)     = %1.4e\n"          first(m.f_vals)
    @printf io "  ||∇f(xₖ)|| = %1.4e\n\n"       first(m.g_norms)
    @printf io "  Terminal Iteration: k = %d\n" m.k
    @printf io "  f(xₖ)      = %1.4e\n"         last(m.f_vals)
    @printf io "  ||∇f(xₖ)|| = %1.4e\n\n"       last(m.g_norms) 
    @printf io "  Minimum Δ:      %1.4e\n"      minimum(m.Δ_vals)
    @printf io "  Minimum Step:   %1.4e\n"      minimum(m.p_vals)
    @printf io "  Minimum f:      %1.4e\n"      minimum(m.f_vals)
    @printf io "  Minimum ||∇f||: %1.4e\n"      minimum(m.g_norms)
end


function log_display(v, name::String)
    if (m=minimum(v)) > 0.0
        return v
    elseif m ≈ 0.0
        @warn "$name: shifted by $(eps(Float64)) to display on Log Scale"
        return v .+ eps(Float64)
    end
    @warn "$name: shifted by $m to display on Log Scale"
    return v .+ m
end


@userplot ObjTrace
@recipe function f(result::ObjTrace)
    xguide := "Steps Taken"
    title  --> "Objective Function Trace"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            qn, w, n, name = result.args[i].d.QN, result.args[i].d.w, result.args[i].d.n, result.args[i].d.name
            v = log_display(result.args[i].f_vals, name)
            labels[1,i] = "\$ ~ f_k\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$name}\$"
            push!(x, v)
        end
        label --> labels
        x
    end
end

@userplot GradTrace
@recipe function f(result::GradTrace)
    xguide := "Steps Taken"
    title  --> "Normed Gradient Trace"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            qn, w, n, name = result.args[i].d.QN, result.args[i].d.w, result.args[i].d.n, result.args[i].d.name
            labels[1,i] = "\$~ \\nabla f_k\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$name}\$"
            push!(x, result.args[i].g_norms)
        end
        label --> labels
        x
    end
end

@userplot RadiusTrace
@recipe function f(result::RadiusTrace)
    xguide := "Steps Taken"
    title  --> "Trust-Region Subproblem Radius Trace"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            qn, w, n, name = result.args[i].d.QN, result.args[i].d.w, result.args[i].d.n, result.args[i].d.name
            labels[1,i] = "\$~ \\Delta_k\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$name}\$"
            push!(x, result.args[i].Δ_vals)
        end
        label --> labels
        x
    end
end

@userplot StepTrace
@recipe function f(result::StepTrace)
    xguide := "Steps Taken"
    title  --> "Step Distance Trace"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            qn, w, n, name = result.args[i].d.QN, result.args[i].d.w, result.args[i].d.n, result.args[i].d.name

            labels[1,i] = "\$~ ||p_k~|| \\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$name}\$"
            push!(x, result.args[i].p_vals)
        end
        label --> labels
        x
    end
end

@userplot RhoTrace
@recipe function f(result::RhoTrace)
    xguide :=  "Steps Taken"
    title  --> "Actual Reduction to Model Reduction Ratio Trace"
    yaxis  --> :log
    legend --> :topright
    @series begin
        x = []
        labels = Matrix{String}(undef, 1, length(result.args))
        for i ∈ 1:length(result.args)
            qn, w, n, name = result.args[i].d.QN, result.args[i].d.w, result.args[i].d.n, result.args[i].d.name
            labels[1,i] = "\$~ \\rho_k\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$name}\$"
            push!(x, result.args[i].ρ_vals)
        end
        label --> labels
        x
    end
end

export rhotrace, rhotrace!, steptrace, steptrace!, radiustrace, radiustrace!, objtrace, objtrace!, gradtrace, gradtrace!