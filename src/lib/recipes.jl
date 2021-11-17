export rhotrace, rhotrace!, steptrace, steptrace!, radiustrace, radiustrace!, objtrace, objtrace!, gradtrace, gradtrace!


# TODO: Currently working with trace, make this work for all lib objects.
# TODO: Check input types, make dir and name seperate in model, add names. 


function log_display(v, name)

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
    num_args = length(result.args)

    m = model(result.args[1])

    y_lab = (isa(formula(m), Missing) || num_args > 1 ? "\$ f \$" : formula(m))

    xguide := "Iterates (gHS evaluations)"

    yguide := y_lab 

    yguidefontsize := 7

    xguidefontsize := 7

    title  --> "Objective Trace"

    titlefontsize --> 11

    yaxis  --> :log

    legend --> :topright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, num_args)

        # Current idea is to accept trace, backend, simulation objects (may need to include model, driver in simulation.jl)
        for i ∈ 1:num_args

            s = result.args[i]
            
            qn_update = string(QN_update(driver(s)))
            
            s_update = "6.1."*string(S_update(driver(s)))[end]
            
            two_w = samples(driver(s))
            
            dim =  dimension(model(s))
            
            id = name(model(s))

            v = log_display(f_vals(s), id)
            
            labels[1,i] = "\$ f \\quad \\mathrm{$id}: ~ n=$dim \\quad 2w=$two_w \\quad (\\mathrm{$s_update}) \\quad \\mathrm{$qn_update} \$"

            push!(x, v)
        end

        label --> labels

        x
    end
end


@userplot GradTrace


@recipe function f(result::GradTrace)
    num_args = length(result.args)

    m = model(result.args[1])

    y_lab = (isa(formula(m), Missing) || num_args > 1 ? "\$ f \$" : formula(m))

    xguide := "Iterates (gHS evaluations)"

    yguide := y_lab 

    yguidefontsize := 7

    xguidefontsize := 7

    title  --> "Normed Gradient Trace"

    titlefontsize --> 11

    yaxis  --> :log

    legend --> :topright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, num_args)

        for i ∈ 1:num_args

            s = result.args[i]
            
            qn_update = string(QN_update(driver(s)))
            
            s_update = "6.1."*string(S_update(driver(s)))[end]
            
            two_w = samples(driver(s))
            
            dim =  dimension(model(s))
            
            id = name(model(s))

            v = log_display(∇f_norms(s), id)
            
            labels[1,i] = "\$ ||\\nabla f|| ~ \\mathrm{$id}: ~ n=$dim \\quad 2w=$two_w \\quad (\\mathrm{$s_update}) \\quad \\mathrm{$qn_update} \$"

            push!(x, v)
        end

        label --> labels

        x
    end
end


@userplot RadiusTrace


@recipe function f(result::RadiusTrace)

    xguide := "Successful Steps"

    yguide := "\$ \\Delta_k \$"

    yguidefontsize := 7

    xguidefontsize := 7

    title  --> "Trust-Region Subproblem Radius Trace"

    titlefontsize --> 11

    yaxis  --> :log

    legend --> :topright
    
    @series begin
        x = []
        
        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            s = result.args[i]
            
            qn_update = string(QN_update(driver(s)))
            
            s_update = "6.1."*string(S_update(driver(s)))[end]
            
            two_w = samples(driver(s))
            
            dim =  dimension(model(s))
            
            id = name(model(s))

            v = log_display(Δ_vals(s), id)

            labels[1,i] = "\$ \\Delta_k ~ \\mathrm{$id}: ~ n=$dim \\quad 2w=$two_w \\quad (\\mathrm{$s_update}) \\quad \\mathrm{$qn_update} \$"

            push!(x, v)
        end

        label --> labels

        x
    end
end


@userplot StepTrace


@recipe function f(result::StepTrace)

    xguide := "Successful Steps"

    yguide := "\$ ||p_k|| \$"

    yguidefontsize := 7

    xguidefontsize := 7

    title  --> "Step Distance Trace"

    titlefontsize --> 11

    yaxis  --> :log

    legend --> :topright
    
    @series begin
        x = []
        
        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            s = result.args[i]
            
            qn_update = string(QN_update(driver(s)))
            
            s_update = "6.1."*string(S_update(driver(s)))[end]
            
            two_w = samples(driver(s))
            
            dim =  dimension(model(s))
            
            id = name(model(s))

            v = log_display(p_norms(s), id)

            labels[1,i] = "\$ ||p_k|| ~ \\mathrm{$id}: ~ n=$dim \\quad 2w=$two_w \\quad (\\mathrm{$s_update}) \\quad \\mathrm{$qn_update} \$"

            push!(x, v)
        end

        label --> labels
        
        x
    end

end


@userplot RhoTrace


@recipe function f(result::RhoTrace)

    xguide := "Successful Steps"

    yguide := "\$ \\rho \$"

    yguidefontsize := 7

    xguidefontsize := 7

    title  --> "Actual Reduction to Model Reduction Ratio Trace"

    titlefontsize --> 11

    yaxis  --> :log

    legend --> :topright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            s = result.args[i]
            
            qn_update = string(QN_update(driver(s)))
            
            s_update = "6.1."*string(S_update(driver(s)))[end]
            
            two_w = samples(driver(s))
            
            dim =  dimension(model(s))
            
            id = name(model(s))

            v = log_display(ρ_vals(s), id)

            labels[1,i] = "\$ \\rho_k ~ \\mathrm{$id}: ~ n=$dim \\quad 2w=$two_w \\quad (\\mathrm{$s_update}) \\quad \\mathrm{$qn_update} \$"

            push!(x, v)
        end

        label --> labels

        x
    end
end