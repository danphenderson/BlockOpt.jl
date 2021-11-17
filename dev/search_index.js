var documenterSearchIndex = {"docs":
[{"location":"manual/model/","page":"Model","title":"Model","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\nimport BlockOpt: Model, name, obj, grad!, grad, objective, gradient, initial_iterate, formula,\n    dimension, directory, objective!, gradient!, initial_iterate!, formula!,\n    hess_sample, hessAD\nend","category":"page"},{"location":"manual/model/#Model","page":"Model","title":"Model","text":"","category":"section"},{"location":"manual/model/","page":"Model","title":"Model","text":"Model","category":"page"},{"location":"manual/model/#BlockOpt.Model","page":"Model","title":"BlockOpt.Model","text":"Model\n\nSpecifies the unconstrianed minimization of a smooth objective function. A model is minimally constructed with a name and may be incrementally loaded. Once a model is loaded, the objective, and gradient function may no longer be modified. A model creates a directory, which stores logged information throughout an instances life.\n\n\n\n\n\n","category":"type"},{"location":"manual/model/#Interface","page":"Model","title":"Interface","text":"","category":"section"},{"location":"manual/model/","page":"Model","title":"Model","text":"name\nobjective\ngradient\ninitial_iterate\nformula\ndimension\ndirectory\nobjective!\ngradient!\ninitial_iterate!\nformula!\nobj\ngrad!\nhessAD\nhess_sample","category":"page"},{"location":"manual/model/#BlockOpt.name","page":"Model","title":"BlockOpt.name","text":"name(m::Model)\n\nThe name of model m.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.objective","page":"Model","title":"BlockOpt.objective","text":"objective(m::Model)\n\nThe objective function of model m, having an unassigned default value of missing.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.gradient","page":"Model","title":"BlockOpt.gradient","text":"gradient(m::Model)\n\nThe gradient function of model m, having an unassigned default value of missing.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.initial_iterate","page":"Model","title":"BlockOpt.initial_iterate","text":"initial_iterate(m::Model)\n\nThe initial iterate of model m, having an unassigned default value of missing.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.formula","page":"Model","title":"BlockOpt.formula","text":"formula(m::Model)\n\nThe formula of model m, having an unassigned default value of missing.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.dimension","page":"Model","title":"BlockOpt.dimension","text":"dimension(m::Model)\n\nThe dimension of model m, which is missing so long as the initial iterate isn't specified.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.directory","page":"Model","title":"BlockOpt.directory","text":"directory(m::Model)\n\nThe directory path of model m, with the relative portion given by the name of m.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.objective!","page":"Model","title":"BlockOpt.objective!","text":"objective!(m::Model, f)\n\nAssign model m the objective function f.\n\nIf the model is final, the call simply returns without modifying the model.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.gradient!","page":"Model","title":"BlockOpt.gradient!","text":"gradient!(m::Model, ∇f!)\n\nAssign model m the in-place gradient function ∇f!, of the form\n\n∇f!(out, x) = (out .= ∇f(x))\n\nwhere ∇f(x) is the steepest descent direction at x in stored the place of the inputed buffer out.\n\nIf the model is final, the call simply returns without modifying the model.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.initial_iterate!","page":"Model","title":"BlockOpt.initial_iterate!","text":"initial_iterate!(m::Model, x0)\n\nAssign model m an initial starting location, ideally a resonable guess of a minima for the models objective function.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.formula!","page":"Model","title":"BlockOpt.formula!","text":"formula!(m::Model, f)\n\nAssign model m an escaped LaTex string, for example \n\ndot_formila = \"$ f(x) = x⋅x $\" \n\nformula!(out, dot_formila)\n\nassigns the euclidean squared distance as the models objective function formula.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.obj","page":"Model","title":"BlockOpt.obj","text":"obj(m::Model, x)\n\nEvaluates the objective function of model m at x.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.grad!","page":"Model","title":"BlockOpt.grad!","text":"grad!(m::Model, out, x)\n\nEvaluates the in-place gradient function of model m at x, storing the steepest descent direction in the place of input buffer out.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.hessAD","page":"Model","title":"BlockOpt.hessAD","text":"hessAD(m::Model, x)\n\nThe dense Hessian matrix of model m's objective function at the point x. The computation uses ForwardDiff.jacobian forward-mode AD function on the model's  gradient function.\n\n\n\n\n\n","category":"function"},{"location":"manual/model/#BlockOpt.hess_sample","page":"Model","title":"BlockOpt.hess_sample","text":"hess_sample(m::Model, x, dx)\n\nThe Hessian vector-product of model m's objective function at the point x  with the vector dx.\n\n\n\n\n\n","category":"function"},{"location":"overview/design/","page":"-","title":"-","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\n    import BlockOpt: Model, Driver, DriverOptions, Simulation, BlockOptTrace, BlockOptBackend, optimize\nend","category":"page"},{"location":"overview/design/#Design","page":"-","title":"Design","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"The BlockOpt interface is constructed through a delegation design pattern, leveraging the behavior of existing types by wrapping them in new types. The figure below is a visual representation of the BlockOpt type delegation, where the arrow represents a has-a relationship. ","category":"page"},{"location":"overview/design/","page":"-","title":"-","text":"(Image: )","category":"page"},{"location":"overview/design/","page":"-","title":"-","text":"Here, the blue shaded types are exposed to the user. The red boxes   holds Algorithm 7.1's iteration information and all observations.","category":"page"},{"location":"overview/design/","page":"-","title":"-","text":"The immutable Driver has-a mutable DriverOptions, which effictively delegates the  simulation options to the Driver via forwarded/inherted functionality. A user-loaded Model and Driver instances are passed to the Simulation type. Then the Simulation controls the entry-point and exit-point of the iteration. Last, a Trace records Backend information throughout the iteration and a Simulation controls the observations information flow. ","category":"page"},{"location":"overview/design/#Exported-Types","page":"-","title":"Exported Types","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"DriverOptions\nDriver\nModel","category":"page"},{"location":"overview/design/#Internal-Types","page":"-","title":"Internal Types","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"Simulation\nBlockOptBackend\nBlockOptTrace","category":"page"},{"location":"overview/design/#BlockOpt.BlockOptBackend","page":"-","title":"BlockOpt.BlockOptBackend","text":"BlockOptBackend\n\nPerforms the iteration of Algorithm 7.1 after being initiated by a Simulation instance.\n\n\n\n\n\n","category":"type"},{"location":"overview/design/#BlockOpt.BlockOptTrace","page":"-","title":"BlockOpt.BlockOptTrace","text":"BlockOptTrace\n\nComposite type responsible for logging, generating Weave  reports, and storing a Profile of the simulation.\n\n\n\n\n\n","category":"type"},{"location":"overview/design/#Optimize","page":"-","title":"Optimize","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"optimize","category":"page"},{"location":"overview/design/#BlockOpt.optimize","page":"-","title":"BlockOpt.optimize","text":"optimize(model::Model, driver::Driver)\n\nAn entry-point into the minimization iteration with the given model subject to the specified driver.\n\n\n\n\n\noptimize(model::Model, driver::Driver)\n\nAttempts to determine the unconstrained minimum of f via a first-order method with the initial iterate given by x₀. The gradient ∇f! must be specified as an inplace operation.\n\n\n\n\n\n","category":"function"},{"location":"overview/design/#Entry-Point:-optimize-call.","page":"-","title":"Entry Point: optimize call.","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"The entry-point occurs when a user makes a function call to optimize.","category":"page"},{"location":"overview/design/#Exit-Point:-optimize-return.","page":"-","title":"Exit Point: optimize return.","text":"","category":"section"},{"location":"overview/design/","page":"-","title":"-","text":"Upon an optimize call a Simulation instance s is created and passed to the fallback method optimize!(s). The exit-point occurs when optimize! returns  simulation s at a terminal state. ","category":"page"},{"location":"manual/options/","page":"Options","title":"Options","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\nimport BlockOpt: DriverOptions, samples, Δ_max, δ_tol, ϵ_tol, max_iterations, weave_level, log_level,\n    samples!, Δ_max!, δ_tol!, ϵ_tol!, max_iterations!, weave_level!, log_level!\nend","category":"page"},{"location":"manual/options/#Options","page":"Options","title":"Options","text":"","category":"section"},{"location":"manual/options/","page":"Options","title":"Options","text":"DriverOptions","category":"page"},{"location":"manual/options/#BlockOpt.DriverOptions","page":"Options","title":"BlockOpt.DriverOptions","text":"DriverOptions\n\nSpecifies Driving parameters of a Simulation instance.\n\n\n\n\n\n","category":"type"},{"location":"manual/options/#Interface","page":"Options","title":"Interface","text":"","category":"section"},{"location":"manual/options/","page":"Options","title":"Options","text":"samples\nΔ_max\nδ_tol\nϵ_tol\nmax_iterations\nweave_level\nlog_level\nsamples!\nΔ_max!\nδ_tol!\nϵ_tol!\nmax_iterations!\nweave_level!\nlog_level!","category":"page"},{"location":"manual/options/#BlockOpt.samples","page":"Options","title":"BlockOpt.samples","text":"samples(o::DriverOptions)\n\nThe number of hessian samples taken at each succussful step in a simulation. \n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.Δ_max","page":"Options","title":"BlockOpt.Δ_max","text":"Δ_max(o::DriverOptions)\n\nThe maximum trust-region radius of a driven simulation.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.δ_tol","page":"Options","title":"BlockOpt.δ_tol","text":"δ_tol(o::DriverOptions)\n\nThe relative tolerance passed to pinv while performing a block QN update.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.ϵ_tol","page":"Options","title":"BlockOpt.ϵ_tol","text":"ϵ_tol(o::DriverOptions)\n\nThe absolute convergence tolerance, occuring at xₖ such that f(xₖ)  ϵ.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.max_iterations","page":"Options","title":"BlockOpt.max_iterations","text":"max_iterations(o::DriverOptions)\n\nThe maximum number of iterations for a driven simulation.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.weave_level","page":"Options","title":"BlockOpt.weave_level","text":"weave_level(o::DriverOptions)\n\nReturns the current weave level of a simulation.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.log_level","page":"Options","title":"BlockOpt.log_level","text":"log_level(o::DriverOptions)\n\nReturns the current logging level of a simulation\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.samples!","page":"Options","title":"BlockOpt.samples!","text":"samples!(o::DriverOptions, s)\n\nSet the number of hessian samples collected during each succussful step to some even natrual s where s = 2w.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.Δ_max!","page":"Options","title":"BlockOpt.Δ_max!","text":"δ_tol!(o::DriverOptions, δ)\n\nSet the maximum trust-region radius to some positive Δ.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.δ_tol!","page":"Options","title":"BlockOpt.δ_tol!","text":"δ_tol!(o::DriverOptions, δ)\n\nSet the pinv relative tolerance used in the QN update to some positive δ.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.ϵ_tol!","page":"Options","title":"BlockOpt.ϵ_tol!","text":"ϵ_tol!(o::DriverOptions, ϵ)\n\nSet the terminal convergence tolerance to some positive ϵ.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.max_iterations!","page":"Options","title":"BlockOpt.max_iterations!","text":"max_iterations!(o::DriverOptions, K)\n\nSet the terminal iteration to the positive integer K.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.weave_level!","page":"Options","title":"BlockOpt.weave_level!","text":"weave_level!(o::DriverOptions, level::WeaveLevel)\n\nSet the weave level to NONE or ALL, toggiling the optional Weave.jl generated report of a simulation.\n\n\n\n\n\n","category":"function"},{"location":"manual/options/#BlockOpt.log_level!","page":"Options","title":"BlockOpt.log_level!","text":"log_level!(o::DriverOptions, level::LogLevel)\n\nAssign the simulation logging level to INFO, DEBUG, WARN, or ERROR.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/","page":"Simulation","title":"Simulation","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\nimport BlockOpt: Simulation, trs_timer, trs_counter, ghs_timer, ghs_counter, f_vals, ∇f_norms, p_norms,\n    Δ_vals, ρ_vals\nend","category":"page"},{"location":"manual/simulation/#Simulation","page":"Simulation","title":"Simulation","text":"","category":"section"},{"location":"manual/simulation/","page":"Simulation","title":"Simulation","text":"Simulation","category":"page"},{"location":"manual/simulation/#BlockOpt.Simulation","page":"Simulation","title":"BlockOpt.Simulation","text":"Simulation\n\nEnty point and exit point of an iteration. A simulation composes a iterations trace and backend iteration of Algorithm 7.1.  An instance of a simulation is returned from an optimize call. \n\n\n\n\n\n","category":"type"},{"location":"manual/simulation/#Interface","page":"Simulation","title":"Interface","text":"","category":"section"},{"location":"manual/simulation/","page":"Simulation","title":"Simulation","text":"trs_timer\ntrs_counter\nghs_timer\nghs_counter\nf_vals\n∇f_norms\np_norms\nΔ_vals\nρ_vals","category":"page"},{"location":"manual/simulation/#BlockOpt.trs_timer","page":"Simulation","title":"BlockOpt.trs_timer","text":"trs_timer\n\nThe elapsed time simulation s has spent in trs_solve(s).\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.trs_counter","page":"Simulation","title":"BlockOpt.trs_counter","text":"trs_counter\n\nThe count of trust region subproblem subsolves of simulation s.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.ghs_timer","page":"Simulation","title":"BlockOpt.ghs_timer","text":"ghs_timer\n\nThe elapsed time simulation s has spent in gHS(s).\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.ghs_counter","page":"Simulation","title":"BlockOpt.ghs_counter","text":"ghs_counter\n\nThe number of gHS evaluations of simulation s.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.f_vals","page":"Simulation","title":"BlockOpt.f_vals","text":"f_vals\n\nA vector storing objective values f(xₖ) for each iterate xₖ.\n\nf_vals gets updated at each accepted step.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.∇f_norms","page":"Simulation","title":"BlockOpt.∇f_norms","text":"∇f_norms\n\nA vector storing normed gradient values f(xₖ)₂ for each iterate xₖ.\n\n∇f_norms gets updated at each accepted step.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.p_norms","page":"Simulation","title":"BlockOpt.p_norms","text":"p_norms\n\nA vector storing the distance of each step pₖ₂. \n\np_norms gets updated at each accepted step.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.Δ_vals","page":"Simulation","title":"BlockOpt.Δ_vals","text":"Δ_vals\n\nA vector storing the trust-region radius passed to trs_small of TRS.jl, during each succussful trust-region subproblem solve. \n\nΔ_vals gets updated at each accepted step.\n\n\n\n\n\n","category":"function"},{"location":"manual/simulation/#BlockOpt.ρ_vals","page":"Simulation","title":"BlockOpt.ρ_vals","text":"ρ_vals\n\nA vector storing the ratio of actual reduction to model reduction of each successful step.\n\nρ_vals gets updated at each accepted step.\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/","page":"Driver","title":"Driver","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\n    import BlockOpt: Driver, pflag, QN_update, SR1, PSB, S_update, S_update_a,\n        S_update_b, S_update_c, S_update_d, S_update_e, S_update_f\nend","category":"page"},{"location":"manual/driver/#Driver","page":"Driver","title":"Driver","text":"","category":"section"},{"location":"manual/driver/","page":"Driver","title":"Driver","text":"Driver","category":"page"},{"location":"manual/driver/#BlockOpt.Driver","page":"Driver","title":"BlockOpt.Driver","text":"Driver\n\nSpecifies the driving parameters of a Simulation instance. A driver is assigned an immutable S_update, QN_update, and pflag upon construction.\n\n\n\n\n\n","category":"type"},{"location":"manual/driver/#Interface","page":"Driver","title":"Interface","text":"","category":"section"},{"location":"manual/driver/","page":"Driver","title":"Driver","text":"SR1\nPSB\nS_update_a\nS_update_b\nS_update_c\nS_update_d\nS_update_e\nS_update_f\npflag\nQN_update\nS_update","category":"page"},{"location":"manual/driver/#BlockOpt.SR1","page":"Driver","title":"BlockOpt.SR1","text":"SR1\n\nReturns the algebraically mininimal SR1 inverse Quasi-Newton block update satisfying the inverse multi-secant condition H  V = U, where δ is the Moore-Penrose psuedoinverse relative tolerance. \n\nSee: Algorithm 42\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.PSB","page":"Driver","title":"BlockOpt.PSB","text":"PSB\n\nPowell-Symmetric-Broyden generalized Quasi-Newton block update, where δ is the Moore-Penrose psuedoinverse relative tolerance. \n\nSee: Algorithm 43\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_a","page":"Driver","title":"BlockOpt.S_update_a","text":"S_update_a\n\nRandom set of orthonormal sample directions. \n\nSee: Equation (6.1.a).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_b","page":"Driver","title":"BlockOpt.S_update_b","text":"S_update_b\n\nRandom set of sample directions orthogonal to the pervious sample space given by input Sₖ.\n\nSee: Equation (6.1.b).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_c","page":"Driver","title":"BlockOpt.S_update_c","text":"S_update_c\n\nAttempts to guide algorithm to accurately resolve eigen-space associated with the larger Hessian eigenvalues.\n\nSee: Equation (6.1.c).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_d","page":"Driver","title":"BlockOpt.S_update_d","text":"S_update_d\n\nVariant of (6.1.a) that includes approximate curvature information along the previously choosen step. \n\nSee: Equation (6.1.d).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_e","page":"Driver","title":"BlockOpt.S_update_e","text":"S_update_e\n\nVariant of (6.1b) that includes approximate curvature information along the previously choosen step. \n\nSee: Equation (6.1.e).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update_f","page":"Driver","title":"BlockOpt.S_update_f","text":"S_update_f\n\nVariant of (6.1c) that includes approximate curvature information along the previously choosen step. \n\nSee: Equation (6.1.f).\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.pflag","page":"Driver","title":"BlockOpt.pflag","text":"pflag\n\nThe preliminary secant QN update flag of driver D.\n\nSee: SR1, PSB\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.QN_update","page":"Driver","title":"BlockOpt.QN_update","text":"QN_update\n\nThe QN update formula of Driver d.\n\nSee: SR1, PSB\n\n\n\n\n\n","category":"function"},{"location":"manual/driver/#BlockOpt.S_update","page":"Driver","title":"BlockOpt.S_update","text":"S_update\n\nThe supplemental sample direction update formula of Driver d.\n\nSee: S_update, S_update_a, S_update_b, S_update_c, S_update_d, S_update_e, S_update_f\n\n\n\n\n\n","category":"function"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"CurrentModule = BlockOpt\nDocTestSetup = quote\n    using BlockOpt\n    using LinearAlgebra\nend","category":"page"},{"location":"tutorials/simple/#Simple-Use-Case","page":"Simple Use Case","title":"Simple Use Case","text":"","category":"section"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"We consider finding an unconstrained minimum of the generalized rosenbrock where the objective function is","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"f(x) = sum_i=1^N-1 left100(x_i+1^2 - x_i^2)^2 + (1 - x_i)^2right","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Translating the objective function into julia code below.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> function rosen(x)\n           N = lastindex(x)\n           100sum((x[i+1] - x[i]^2)^2 for i = 1:N-1) + sum((x[i] - 1)^2 for i = 1:N-1)\n       end","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"The simulation terminatates when the first-order neccessary condition for the generalized rosenbrock's gradient f is satisfied, i.e.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":" nabla f(x)  leq epsilon","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Differentiating the objective function and translating to julia code.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> function ∇rosen!(g, x)\n           N = lastindex(x)\n           g[1] = -2*(1 - x[1]) - 400*x[1]*(-x[1]^2 + x[2])\n\n           for i in 2:N-1\n               g[i] = -2*(1 - x[i]) + 200*(-x[i-1]^2 + x[i]) - 400*x[i]*(-x[i]^2 + x[1 + i])\n           end\n           \n           g[N] = 200 * (x[N] - x[N-1]^2)    \n           return g\n       end\n∇rosen! (generic function with 1 method)","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Consider dimension n=100 and randomly select x₀ from the the 100-dimensional hypercube.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> x₀ = randn(100);","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Then our call to optimize is the entry-point of the unconstrained minimization interation. ","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> optimize(rosen, ∇rosen!, x₀)\nSUCCESS 8.070336658758971e-7 ≤ 1.0e-5 in 528 steps\n--------------------------------------\n  Minimum f:      5.311172726630893e-16\n  Minimum ||∇f||: 8.070336658758971e-7\n  Minimum Δ:      0.005844719845773086\n  Minimum Step:   6.030122388810338e-8\n\n  Model: \n  -------------------\n    objective:         rosen\n    gradient:          ∇rosen!\n    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]\n    dimension:         100\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Missing\n    objective formula: missing\n  Driver:\n  -------------------\n    S_update:  S_update_c\n    QN_update: SR1\n    pflag:     false\n    Options:\n      samples:        6\n      Δ_max:          100.0\n      δ_tol:          1.0e-12\n      ϵ_tol:          1.0e-5\n      max_iterations: 2000\n  Trace:\n  -------------------\n    Weaver:\n      f_vals:   [37156.548946, ..., 0.000000, 0.000000, 0.000000]\n      ∇f_norms: [15116.003941, ..., 0.000293, 0.000016, 0.000001]\n      Δ_vals:   [5.984993, ..., 0.187031, 0.187031, 0.187031]\n      p_norms:  [5.172082, ..., 0.000045, 0.000002, 0.000000]\n      ρ_vals:   [0.931152, ..., 0.985198, 0.983784, 0.986492]\n    Profile:\n      trs_counter: 528\n      trs_timer:   0.07330679893493652\n      ghs_counter: 430\n      ghs_timer:   0.07087516784667969","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Here, the output is showing a Simulation instance in it's terminal state, which happens to be a success!","category":"page"},{"location":"tutorials/simple/#Constructing-a-Model","page":"Simple Use Case","title":"Constructing a Model","text":"","category":"section"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"We extend our simple use case to define a model, which creates a directory to keep track of simulations throughout the model's life.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> m = Model(\"Rosenbrock\")\n  Model: \n  -------------------\n    objective:         missing\n    gradient:          missing\n    initial iterate:   missing\n    dimension:         missing\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock\n    objective formula: missing","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Above is an empty model which is incrementally loaded.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> objective!(m, rosen)\nrosen (generic function with 1 method)\n\njulia> gradient!(m, ∇rosen!)\n∇rosen! (generic function with 1 method)\n\njulia> initial_iterate!(m, x₀); m\n  Model: \n  -------------------\n    objective:         rosen\n    gradient:          ∇rosen!\n    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]\n    dimension:         100\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock\n    objective formula: missing","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"The model is now loaded to a final state, meaning that the objective and gradient function can no longer be modified. ","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"We may optionally choose to specify a formula repsenting the objective of m.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> rosen_formula = \"\\$\\\\sum_{i=1}^{N-1} \\\\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\\\right]\\$\";\n\njulia> formula!(m, rosen_formula)\n\"\\$\\\\sum_{i=1}^{N-1} \\\\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\\\right]\\$\"\n\njulia> m\n  Model: \n  -------------------\n    objective:         rosen\n    gradient:          ∇rosen!\n    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]\n    dimension:         100\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock\n    objective formula: $\\sum_{i=1}^{N-1} \\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\right]$","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Our model m is now fully constructed. One thing to note is the directory above,  which was created when declaring the model m. The Model's constructor creates a directory relative to the user's current working directory (as determined by a pwd() call). The relative portion to the user's working enviroment is created from the models name, in our case \\Rosenbrock.","category":"page"},{"location":"tutorials/simple/#Constructing-a-Driver","page":"Simple Use Case","title":"Constructing a Driver","text":"","category":"section"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"The goal of creating a model is to record simulation information over multiples trials, where each trial incorporates the second-order hessian information into each step's QN update in a unique manner. This is done through construction of a driver.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> default = Driver() # default parameters and options\n  Driver:\n  -------------------\n    S_update:  S_update_c\n    QN_update: SR1\n    pflag:     false\n    Options:\n      samples:        6\n      Δ_max:          100.0\n      δ_tol:          1.0e-12\n      ϵ_tol:          1.0e-5\n      max_iterations: 2000","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"The default driver is what was used in the simple use case above. We can alternatively specify keyward arguments to the constructor.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> psb_default = Driver(QN_update = PSB)\n  Driver:\n  -------------------\n    S_update:  S_update_c\n    QN_update: PSB\n    pflag:     false\n    Options:\n      samples:        6\n      Δ_max:          100.0\n      δ_tol:          1.0e-12\n      ϵ_tol:          1.0e-5\n      max_iterations: 2000","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"See pflag and S_update for information on the other keyword arguments.","category":"page"},{"location":"tutorials/simple/#Configurations","page":"Simple Use Case","title":"Configurations","text":"","category":"section"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"By dispatching optimize on a user-defined model and driver, it allows us to make meaningfull comparisions between different parameters.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> optimize(m, psb_default)\nFAIL 3.3237010117680144 ≰ 1.0e-5 in 2000 steps\n--------------------------------------\n  Minimum f:      27.704563096307897\n  Minimum ||∇f||: 2.55525408127963\n  Minimum Δ:      0.005317424470907392\n  Minimum Step:   0.005317424470907389\n\n  Model: \n  -------------------\n    objective:         rosen\n    gradient:          ∇rosen!\n    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]\n    dimension:         100\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock\n    objective formula: $\\sum_{i=1}^{N-1} \\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\right]$\n  Driver:\n  -------------------\n    S_update:  S_update_c\n    QN_update: PSB\n    pflag:     false\n    Options:\n      samples:        6\n      Δ_max:          100.0\n      δ_tol:          1.0e-12\n      ϵ_tol:          1.0e-5\n      max_iterations: 2000\n  Trace:\n  -------------------\n    Weaver:\n      f_vals:   [37156.548946, ..., 27.774588, 27.740267, 27.704563]\n      ∇f_norms: [15116.003941, ..., 3.329326, 3.680141, 3.323701]\n      Δ_vals:   [5.445043, ..., 0.021270, 0.021270, 0.021270]\n      p_norms:  [4.350945, ..., 0.014781, 0.014780, 0.014779]\n      ρ_vals:   [1.117260, ..., 1.675970, 1.665151, 1.676431]\n    Profile:\n      trs_counter: 2000\n      trs_timer:   0.30657124519348145\n      ghs_counter: 1969\n      ghs_timer:   0.2530691623687744","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Here, our simulation failed to reach a successfull terminal state with the psb_driver driver. The next step is to configure the max_iterations of the psb_driver to larger value.","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"julia> max_iterations!(psb_default, 10000)\n10000\n\njulia> optimize(m, psb_default)\nSUCCESS 9.927950264884106e-6 ≤ 1.0e-5 in 5590 steps\n--------------------------------------\n  Minimum f:      5.511229138712141e-11\n  Minimum ||∇f||: 9.927950264884106e-6\n  Minimum Δ:      0.01131181544998996\n  Minimum Step:   6.449591660831643e-8\n\n  Model: \n  -------------------\n    objective:         rosen\n    gradient:          ∇rosen!\n    initial iterate:   [0.132719, ..., 0.554169, -0.861590, -0.025498]\n    dimension:         100\n    directory:         /Users/daniel/.julia/dev/BlockOpt/docs/Rosenbrock\n    objective formula: $\\sum_{i=1}^{N-1} \\left[100(x_{i+1}^2 - x_i^2)^2 + (1 - x_i)^2\\right]$\n  Driver:\n  -------------------\n    S_update:  S_update_c\n    QN_update: PSB\n    pflag:     false\n    Options:\n      samples:        6\n      Δ_max:          100.0\n      δ_tol:          1.0e-12\n      ϵ_tol:          1.0e-5\n      max_iterations: 10000\n  Trace:\n  -------------------\n    Weaver:\n      f_vals:   [37156.548946, ..., 0.000000, 0.000000, 0.000000]\n      ∇f_norms: [15116.003941, ..., 0.000010, 0.000012, 0.000010]\n      Δ_vals:   [5.791650, ..., 0.045247, 0.045247, 0.045247]\n      p_norms:  [4.512299, ..., 0.000000, 0.000000, 0.000000]\n      ρ_vals:   [1.097135, ..., 1.760999, 1.752575, 1.761029]\n    Profile:\n      trs_counter: 5590\n      trs_timer:   0.7602972984313965\n      ghs_counter: 5575\n      ghs_timer:   0.7890379428863525","category":"page"},{"location":"tutorials/simple/","page":"Simple Use Case","title":"Simple Use Case","text":"Allowing for 1000 iterations yeilds first-order neccessary convergence within the specified tolerance, given by an ϵ_tol(psb_default) call. See the Options section of the manual for more information on specifying simulation configurations. ","category":"page"},{"location":"#BlockOpt.jl","page":"BlockOpt.jl","title":"BlockOpt.jl","text":"","category":"section"},{"location":"","page":"BlockOpt.jl","title":"BlockOpt.jl","text":"This application supplements QN Optimization with Hessian Samples, an article currently under review. It's purpose is to explore block Quasi-Newton (QN) updates used in the unconstrained minimization of a smooth objective function, f. ","category":"page"},{"location":"#Documentation-Structure","page":"BlockOpt.jl","title":"Documentation Structure","text":"","category":"section"},{"location":"","page":"BlockOpt.jl","title":"BlockOpt.jl","text":"The Overview section is concerned with the sofware design pattern used.\nThe Manual section holds documentation for the BlockOpt application programable interface.\nThe Tutorial sections provides typical use cases of BlockOpt.jl.","category":"page"},{"location":"tutorials/installation/#Installation","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"The BlockOpt package installs as","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"julia> ]\npkg> add https://github.com/danphenderson/TRS.jl\npkg> add https://github.com/danphenderson/BlockOpt.jl # backspace returns to julia prompt ","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"in the Julia's Pkg REPL mode.","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"In a notebook environment BlockOpt installs as","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"using Pkg\nPkg.add(url=\"https://github.com/danphenderson/TRS.jl\")\nPkg.add(url=\"https://github.com/danphenderson/BlockOpt.jl\")","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"using the Julia package manager Pkg.jl.","category":"page"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"The TRS package is an unregistered package  requirement for BlockOpt.jl. There is an open pull-request to merge the  forked branch of TRS.jl used in this packages trust-region subproblem solve. The pull request focuses on updating the master branch to the latest  evolution of the Julia package management system.","category":"page"}]
}
