module BlockOpt

import Base: @kwdef

include("abstract/abstract.jl") # submodule 

include("util.jl")

include("record.jl")

include("model.jl")

include("options.jl")

include("driver.jl")

include("trace.jl")

include("backend.jl")

include("simulation.jl")

end # module