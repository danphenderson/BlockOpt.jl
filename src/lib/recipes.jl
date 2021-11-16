export rhotrace,
    rhotrace!,
    steptrace,
    steptrace!,
    radiustrace,
    radiustrace!,
    objtrace,
    objtrace!,
    gradtrace,
    gradtrace!


# TODO: Currently working with trace, make this work for all lib objects.
# TODO: Check input types, make dir and name seperate in model, add names. 


function log_display(v, name)

    if (m = minimum(v)) > 0.0

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

    title --> "Objective Trace"

    titlefontsize --> 11

    yaxis --> :log

    legend --> :outerright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, num_args)

        # Current idea is to accept trace, backend, simulation objects (may need to include model, driver in simulation.jl)
        for i ∈ 1:num_args

            t = result.args[i]

            qn, w, n, dir = QN_update(driver(t)),
            samples(driver(t)),
            dimension(model(t)),
            name(model(t))

            v = log_display(f_vals(t), dir)

            #labels[1,i] = "\$ ~ f \\quad \\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n}\$"

            labels[1, i] = "\$~ f ~ w= $w ~ n=$n ~ $qn ~ $dir\$"

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

    title --> "Normed Gradient Trace"

    titlefontsize --> 11

    yaxis --> :log

    legend --> :outerright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, num_args)

        for i ∈ 1:num_args

            t = result.args[i]

            qn, w, n, dir = QN_update(driver(t)),
            samples(driver(t)),
            dimension(model(t)),
            name(model(t))

            labels[1, i] = "\$~ ||\\nabla f|| ~ w= $w ~ n=$n ~ $qn\$"

            push!(x, ∇f_norms(t))
        end

        label --> labels

        x
    end
end


@userplot RadiusTrace


@recipe function f(result::RadiusTrace)
    xguide := "Steps Taken"

    title --> "Trust-Region Subproblem Radius Trace"

    yaxis --> :log

    legend --> :outerright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            t = result.args[i]

            qn, w, n, dir = QN_update(driver(t)),
            samples(driver(t)),
            dimension(model(t)),
            name(model(t))

            labels[
                1,
                i,
            ] = "\$~ \\Delta_k\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$dir}\$"

            push!(x, Δ_vals(t))
        end

        label --> labels

        x
    end
end


@userplot StepTrace


@recipe function f(result::StepTrace)
    xguide := "Steps Taken"

    title --> "Step Distance Trace"

    yaxis --> :log

    legend --> :outerright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            t = result.args[i]

            qn, w, n, dir = QN_update(driver(t)),
            samples(driver(t)),
            dimension(model(t)),
            name(model(t))

            labels[
                1,
                i,
            ] = "\$~ ||p_k~||\\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$dir}\$"

            push!(x, p_norms(t))
        end

        label --> labels

        x
    end

end


@userplot RhoTrace


@recipe function f(result::RhoTrace)
    xguide := "Steps Taken"

    title --> "Actual Reduction to Model Reduction Ratio Trace"

    yaxis --> :log

    legend --> :outerright

    @series begin
        x = []

        labels = Matrix{String}(undef, 1, length(result.args))

        for i ∈ 1:length(result.args)

            t = result.args[i]

            qn, w, n, dir = QN_update(driver(t)),
            samples(driver(t)),
            dimension(model(t)),
            name(model(t))

            labels[
                1,
                i,
            ] = "\$~ \\rho_k \\quad\\mathrm{$qn} ~ w=\\mathrm{$w} \\quad n=\\mathrm{$n} \\quad \\mathrm{$dir}\$"

            push!(x, ρ_vals(t))
        end

        label --> labels

        x
    end
end
