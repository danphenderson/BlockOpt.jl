# Installation

The BlockOpt package installs as

```julia
julia> ]
pkg> add https://github.com/danphenderson/TRS.jl
pkg> add https://github.com/danphenderson/BlockOpt.jl # backspace returns to julia prompt 
```

in the [Julia's Pkg REPL mode](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1).


In a notebook environment BlockOpt installs as
```julia
using Pkg
Pkg.add(url="https://github.com/danphenderson/TRS.jl")
Pkg.add(url="https://github.com/danphenderson/BlockOpt.jl")
```
using the Julia package manager [Pkg.jl](https://pkgdocs.julialang.org/v1/).

The TRS package does not install with the BlockOpt.jl supported Julia release
versions ≥ v1.3.0. The TRS package supports earlier releases of Julia.
The BlockOpt trust-region subproblem solver uses trs_small from an updated TRS.jl
branch, installable on all BlockOpt supported Julia releases. There is an open
pull request to merge the forked TRS branch used in BlockOpt.jl.