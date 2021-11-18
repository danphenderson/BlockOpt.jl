function array_string_view(data)
    isa(data, Missing) && return data

    if length(data) == 1
        return @sprintf "[%f]" data[begin]
    elseif length(data) == 2
        return @sprintf "[%f, ..., %f]" data[begin] data[end]
    elseif length(data) == 3
        return @sprintf "[%f, ..., %f, %f]" data[begin] data[end-1] data[end]
    elseif length(data) ≥ 4
        return @sprintf "[%f, ..., %f, %f, %f]" data[begin] data[end-2] data[end-1] data[end]
    end

    return data # data is empty
end


function header_view(is_suptype::Bool, name)
    is_suptype && begin
        return @sprintf "%4s%s:\n\n" "" name
    end
    return @sprintf "%s:\n--------------------------------------\n" name
end


# TODO: Add a print_field method, that handles offset

# TODO: Add a pretty_print method to round floats


function Base.show(io::IO, m::Model)
    println(io, "  Model: $(name(m))")
    formula_here = (isa(formula(m), Missing) ? formula(m) : "loaded")
    println(io, "  -------------------")
    println(io, "    objective:         $(objective(m))")
    println(io, "    gradient:          $(gradient(m))")
    println(io, "    initial iterate:   $(array_string_view(initial_iterate(m)))")
    println(io, "    dimension:         $(dimension(m))")
    println(io, "    directory:         $(directory(m))")
    println(io, "    objective formula: $(formula_here)")
    flush(io)
    return nothing
end


function Base.show(io::IO, o::DriverOptions)
    println(io, "    Options:")
    println(io, "      samples:        $(samples(o))")
    println(io, "      Δ_max:          $(Δ_max(o))")
    println(io, "      δ_tol:          $(δ_tol(o))")
    println(io, "      ϵ_tol:          $(ϵ_tol(o))")
    println(io, "      max_iterations: $(max_iterations(o))")
    flush(io)
    return nothing
end


function Base.show(io::IO, d::Driver)
    println(io, "  Driver:")
    println(io, "  -------------------")
    println(io, "    S_update:  $(S_update(d))")
    println(io, "    QN_update: $(QN_update(d))")
    println(io, "    pflag:     $(pflag(d))")
    show(io, options(d))
    flush(io)
    return nothing
end


function Base.show(io::IO, w::Weaver)
    println(io, "    Weaver:")
    println(io, "      f_vals:   $(array_string_view(f_vals(w)))")
    println(io, "      ∇f_norms: $(array_string_view(∇f_norms(w)))")
    println(io, "      Δ_vals:   $(array_string_view(Δ_vals(w)))")
    println(io, "      p_norms:  $(array_string_view(p_norms(w)))")
    println(io, "      ρ_vals:   $(array_string_view(ρ_vals(w)))")
    flush(io)
    return nothing
end


function Base.show(io::IO, p::BlockOptProfile)
    println(io, "    Profile:")
    println(io, "      trs_counter: $(evaluations(trs_counter(p)))")
    println(io, "      trs_timer:   $(Δt(trs_timer(p)))")
    println(io, "      ghs_counter: $(evaluations(ghs_counter(p)))")
    println(io, "      ghs_timer:   $(Δt(ghs_timer(p)))")
    flush(io)
    return nothing
end


function Base.show(io::IO, t::BlockOptTrace)
    println(io, "  Trace:")
    println(io, "  -------------------")
    show(io, weaver(t))
    show(io, profile(t))
    flush(io)
    return nothing
end


function Base.show(io::IO, b::BlockOptBackend)
    show(io, model(b))
    show(io, driver(b))
    flush(io)
    return nothing
end


function Base.show(io::IO, s::Simulation)
    if evaluations(trs_counter(s)) == 0
        # initial simulation display
        show(io, model(trace(s)))
        show(io, driver(trace(s)))
    else
        # display after simulation complete
        pass = (∇fₖ_norm(s) ≤ ϵ_tol(backend(s)) ? true : false)
        print(io, "$(pass ? "SUCCESS" : "FAIL")")
        print(io, " $(∇fₖ_norm(s)) $(pass ? "≤" : "≰") $(ϵ_tol(backend(s)))")
        println(io, " in $(evaluations(trs_counter(s))) steps")
        println(io, "--------------------------------------")
        println(io, "  Minimum f:      $(minimum(f_vals(s)))")
        println(io, "  Minimum ||∇f||: $(minimum(∇f_norms(s)))")
        println(io, "  Minimum Δ:      $(minimum(Δ_vals(s)))")
        println(io, "  Minimum Step:   $(minimum(p_norms(s)))")
        println(io, "")
        show(io, backend(s))
        show(io, trace(s))
    end
    println(io, "")
    flush(io)
    return nothing
end


# function show_driver(io::IO, d::Driver)
#     println(io,"\n%s %s Driver: n = %d, w = %d\n" d.name d.QN d.n d.w
#     println(io,"-----------------------------------------------------------\n"
#     println(io,"  Hessian Samples: %d\n" 2*d.w
#     println(io,"  Terminal Conditions: ||∇fₖ|| < %1.2e or %d iterations\n\n" d.ϵ d.max_iter
#     return nothing
# end
