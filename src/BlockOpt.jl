module BlockOpt

import Statistics: mean
using LinearAlgebra, TRS, Dates
using ForwardDiff


include("util.jl")

include("lib/model.jl")

include("lib/options.jl")

include("lib/driver.jl")

include("lib/trace.jl")

include("lib/backend.jl")

include("lib/simulation.jl")


end # module