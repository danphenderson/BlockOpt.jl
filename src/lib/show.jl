function array_string_view(data)
    if length(data) == 1
        return @sprintf "[%1.2e]\n" data[begin]
    elseif length(data) == 2
        return @sprintf "[%1.2e, ..., %1.2e]\n" data[begin] data[end]
    elseif length(data) == 3 
        return @sprintf "[%1.2e, ..., %1.2e, %1.2e]\n" data[begin] data[end-1] data[end]
    elseif length(data) ≥ 4
        return @sprintf "[%1.2e, ..., %1.2e, %1.2e, %1.2e]\n" data[begin] data[end-2] data[end-1] data[end]
    end   
    return "" # data is empty
end


function header_view(is_suptype::Bool, name)
    is_suptype && begin 
        return @sprintf "%4s%s:\n\n" "" name 
    end
    return @sprintf "%s:\n--------------------------------------\n" name 
end


# TODO: Add a print_field method, that handles offset - good enough


function Base.show(io::IO, m::Model)
    x0 = initial_iterate(m)
    x0 = isa(x0, Missing) ? "$(x0)\n" : array_string_view(x0) 
    @printf io "  Model: "
    isa(formula(m), Missing) ? (@printf io "%s\n" formula(m)) : (@printf io "\n")
    @printf io "  -------------------\n"
    @printf io "    objective:       %s\n" "$(objective(m))"
    @printf io "    gradient:        %s\n" "$(gradient(m))"
    @printf io "    initial iterate: %s"    x0
    @printf io "    dimension:       %d\n"  dimension(m)
    @printf io "    directory:       %s\n"  directory(m)
    @printf io "\n"
    flush(io)
    return nothing
end


function Base.show(io::IO, o::DriverOptions)
    @printf io "    Options:\n"
    @printf io "      samples:        %d\n"    samples(o)
    @printf io "      Δ_max:          %1.3e\n" Δ_max(o)
    @printf io "      δ_tol:          %1.3e\n" δ_tol(o)
    @printf io "      ϵ_tol:          %1.3e\n" ϵ_tol(o)
    @printf io "      max_iterations: %d\n"    max_iterations(o)
    flush(io)
    return nothing
end


function Base.show(io::IO, d::Driver)
    @printf io "  Driver:\n"
    @printf io "  -------------------\n"
    @printf io "    S_update:  %s\n"  "$(S_update(d))"
    @printf io "    QN_update: %s\n"  "$(QN_update(d))"
    @printf io "    pflag:     %s\n"  "$(pflag(d))"
    show(options(d))
    @printf io "\n"
    flush(io)
    return nothing
end


function Base.show(io::IO, w::Weaver)
    @printf io "    Weaver:\n"
    @printf io "      f_vals:   %s" array_string_view(f_vals(w))
    @printf io "      ∇f_norms: %s" array_string_view(∇f_norms(w))
    @printf io "      Δ_vals:   %s" array_string_view(Δ_vals(w))
    @printf io "      p_norms:  %s" array_string_view(p_norms(w))
    @printf io "      ρ_vals:   %s" array_string_view(ρ_vals(w))
    flush(io)
    return nothing
end


function Base.show(io::IO, p::BlockOptProfile)
    @printf io "    Profile:\n"
    @printf io "      trs_counter: %d\n"    evaluations(trs_counter(p))
    @printf io "      trs_timer:   %1.3e\n" Δt(trs_timer(p))
    @printf io "      ghs_counter: %d\n"    evaluations(ghs_counter(p))
    @printf io "      ghs_timer:   %1.3e\n" Δt(ghs_timer(p))
    flush(io)
    return nothing
end


function Base.show(io::IO, t::BlockOptTrace)
    @printf io "  Trace:\n"
    @printf io "  -------------------\n"
    show(io, weaver(t))
    show(io, profile(t))
    @printf io "\n"
    flush(io)
    return nothing
end


function Base.show(io::IO, b::BlockOptBackend)
    show(io, model(b))
    show(io, driver(b))
    return nothing
end

# TODO: Consider adding assertion statements to show methods to catch bugs

function Base.show(io::IO, s::Simulation)
    pass = (terminal(s) ?  true : false)
    @printf io "\n%s" (pass ? "SUCCESS" : "FAIL")
    @printf io " %1.2e %s %1.2e"          ∇fₖ_norm(s) (pass ? "≤" : "≰") ϵ_tol(backend(s))
    @printf io " in %d steps\n"         evaluations(trs_counter(s))
    @printf io "--------------------------------------\n"
    @printf io "  Minimum f:      %1.2e\n" minimum(f_vals(s))
    @printf io "  Minimum ||∇f||: %1.2e\n" minimum(∇f_norms(s))
    @printf io "  Minimum Δ:      %1.2e\n" minimum(Δ_vals(s))
    @printf io "  Minimum Step:   %1.2e\n\n" minimum(p_norms(s))
    show(io, backend(s))
    show(io, trace(s))
    return nothing
end


# function show_driver(io::IO, d::Driver)
#     @printf io "\n%s %s Driver: n = %d, w = %d\n" d.name d.QN d.n d.w
#     @printf io "-----------------------------------------------------------\n"
#     @printf io "  Hessian Samples: %d\n" 2*d.w
#     @printf io "  Terminal Conditions: ||∇fₖ|| < %1.2e or %d iterations\n\n" d.ϵ d.max_iter
#     return nothing
# end